import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:nhost_dart/nhost_dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateRoomScreen extends StatefulWidget {
  final NhostClient nhostClient;

  const CreateRoomScreen({Key? key, required this.nhostClient})
    : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  late String roomId;
  bool _copied = false;
  bool _connected = false;
  String? _error;
  bool _isCreating = true;

  @override
  void initState() {
    super.initState();
    roomId = const Uuid().v4().substring(0, 8).toUpperCase();
    // Delay to ensure widget is built
    Future.delayed(Duration.zero, () => _createRoom());
  }

  Future<void> _createRoom() async {
    try {
      final userId = widget.nhostClient.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _error = 'Not authenticated';
          _isCreating = false;
        });
        return;
      }

      final accessToken = widget.nhostClient.auth.accessToken;
      if (accessToken == null) {
        setState(() {
          _error = 'No access token';
          _isCreating = false;
        });
        return;
      }

      const createRoomMutation = r'''
        mutation CreateRoom($roomId: String!, $creatorId: uuid!) {
          insert_rooms_one(object: {
            room_id: $roomId,
            creator_id: $creatorId,
            status: "waiting"
          }) {
            id
            room_id
            status
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
          'query': createRoomMutation,
          'variables': {'roomId': roomId, 'creatorId': userId},
        }),
      );

      final data = json.decode(response.body);

      if (data['errors'] != null) {
        setState(() {
          _error = 'Failed to create room: ${data['errors'][0]['message']}';
          _isCreating = false;
        });
        return;
      }

      setState(() => _isCreating = false);

      // Start polling for opponent (simplified - no subscription for now)
      _pollForOpponent();
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isCreating = false;
      });
    }
  }

  void _pollForOpponent() {
    // Poll every 2 seconds to check if opponent joined
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted || _connected) return;

      try {
        final accessToken = widget.nhostClient.auth.accessToken;
        if (accessToken == null) return;

        const query = r'''
          query GetRoom($roomId: String!) {
            rooms(where: {room_id: {_eq: $roomId}}) {
              status
              opponent_id
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
            'query': query,
            'variables': {'roomId': roomId},
          }),
        );

        final data = json.decode(response.body);
        final rooms = data['data']?['rooms'] as List?;

        if (rooms != null && rooms.isNotEmpty) {
          final status = rooms[0]['status'] as String?;
          if (status == 'connected' && !_connected) {
            setState(() => _connected = true);

            // Auto-navigate to game after 1 second
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                // Creator is ALWAYS RED
                Navigator.of(context).pushReplacementNamed(
                  '/game',
                  arguments: {
                    'boardSize': 4,
                    'roomId': roomId,
                    'playerColor': 'red', // Creator is always RED
                    'isOnline': true,
                  },
                );
              }
            });
            return;
          }
        }

        // Continue polling
        _pollForOpponent();
      } catch (e) {
        // Continue polling even on error
        _pollForOpponent();
      }
    });
  }

  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: roomId));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room ID copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Room'),
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
            colors: [Colors.blue.shade100, Colors.blue.shade50],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Icon(
                  _connected ? Icons.check_circle : Icons.add_circle_outline,
                  size: 100,
                  color: _connected ? Colors.green : Colors.blue.shade700,
                ),
                const SizedBox(height: 32),
                Text(
                  _connected ? 'Room Created!' : 'Creating Room...',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _connected
                      ? 'Share this Room ID with your friend'
                      : 'Setting up your game room',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),
                Container(
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
                      const Text(
                        'Room ID',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        roomId,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _copyRoomId,
                        icon: Icon(_copied ? Icons.check : Icons.copy),
                        label: Text(_copied ? 'Copied!' : 'Copy Room ID'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                if (!_connected)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 16),
                        Text(
                          'Waiting for opponent...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Successfully Connected!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/game',
                        arguments: {
                          'boardSize': 4,
                          'roomId': roomId,
                          'playerColor': 'red', // Creator is Red
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
