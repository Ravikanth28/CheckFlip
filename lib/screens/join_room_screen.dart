import 'package:flutter/material.dart';
import 'package:nhost_dart/nhost_dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JoinRoomScreen extends StatefulWidget {
  final NhostClient nhostClient;

  const JoinRoomScreen({Key? key, required this.nhostClient}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _roomIdController = TextEditingController();
  bool _connecting = false;
  bool _connected = false;
  String? _error;

  Future<void> _joinRoom() async {
    final roomId = _roomIdController.text.trim().toUpperCase();

    if (roomId.isEmpty) {
      setState(() => _error = 'Please enter a room ID');
      return;
    }

    if (roomId.length != 8) {
      setState(() => _error = 'Room ID must be 8 characters');
      return;
    }

    setState(() {
      _connecting = true;
      _error = null;
    });

    try {
      final userId = widget.nhostClient.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _error = 'Not authenticated';
          _connecting = false;
        });
        return;
      }

      final accessToken = widget.nhostClient.auth.accessToken;
      if (accessToken == null) {
        setState(() {
          _error = 'No access token';
          _connecting = false;
        });
        return;
      }

      const joinRoomMutation = r'''
        mutation JoinRoom($roomId: String!, $opponentId: uuid!) {
          update_rooms(
            where: {room_id: {_eq: $roomId}, status: {_eq: "waiting"}},
            _set: {opponent_id: $opponentId, status: "connected"}
          ) {
            affected_rows
            returning {
              id
              room_id
              status
            }
          }
        }
      ''';

      final response = await http.post(
        Uri.parse(widget.nhostClient.gqlEndpointUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'query': joinRoomMutation,
          'variables': {'roomId': roomId, 'opponentId': userId},
        }),
      );

      final data = json.decode(response.body);

      if (data['errors'] != null) {
        setState(() {
          _error = 'Failed to join room: ${data['errors'][0]['message']}';
          _connecting = false;
        });
        return;
      }

      final affectedRows =
          data['data']?['update_rooms']?['affected_rows'] as int? ?? 0;

      if (affectedRows == 0) {
        setState(() {
          _error = 'Room not found or already full';
          _connecting = false;
        });
        return;
      }

      setState(() {
        _connecting = false;
        _connected = true;
      });

      // Auto-navigate to game after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Joiner is ALWAYS BLACK
          Navigator.of(context).pushReplacementNamed(
            '/game',
            arguments: {
              'boardSize': 4,
              'roomId': roomId,
              'playerColor': 'black', // Joiner is always BLACK
              'isOnline': true,
            },
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _connecting = false;
      });
    }
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Room'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade100, Colors.purple.shade50],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _connected ? Icons.check_circle : Icons.login,
                  size: 100,
                  color: _connected ? Colors.green : Colors.purple.shade700,
                ),
                const SizedBox(height: 32),
                Text(
                  _connected ? 'Connected!' : 'Join Room',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _connected
                      ? 'Successfully joined the room'
                      : 'Enter the room ID shared by your friend',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),
                if (!_connected) ...[
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _roomIdController,
                          decoration: InputDecoration(
                            labelText: 'Room ID',
                            hintText: 'Enter 8-character code',
                            prefixIcon: const Icon(Icons.vpn_key),
                            border: const OutlineInputBorder(),
                            errorText: _error,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 4,
                            fontFamily: 'monospace',
                          ),
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 8,
                          onChanged: (value) {
                            if (_error != null) {
                              setState(() => _error = null);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _connecting ? null : _joinRoom,
                            icon: _connecting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(
                              _connecting ? 'Connecting...' : 'Join Room',
                            ),
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Successfully Connected!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Room ID: ${_roomIdController.text.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade700,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/game',
                              arguments: {
                                'boardSize': 4,
                                'roomId': _roomIdController.text.toUpperCase(),
                                'playerColor': 'black', // Opponent is Black
                                'isOnline': true,
                              },
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Game'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
