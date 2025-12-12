import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert';
import '../main.dart';
import '../utils/app_colors.dart';
import 'checkflip_game_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeCtrl = TextEditingController();
  bool _isJoining = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _roomCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isJoining = true);

    try {
      final roomId = _roomCodeCtrl.text.trim();
      final accessToken = nhostClient.auth.accessToken;

      if (accessToken == null) {
        throw Exception('Not authenticated');
      }

      // Check if room exists
      final query = '''
        query GetRoom(\$roomId: String!) {
          rooms(where: {room_id: {_eq: \$roomId}}) {
            id
            room_id
            status
          }
        }
      ''';

      final response = await http.post(
        Uri.parse(nhostClient.gqlEndpointUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'query': query,
          'variables': {'roomId': roomId},
        }),
      );

      print('Join room response: ${response.body}');

      final data = json.decode(response.body);

      if (data['errors'] != null) {
        throw Exception('GraphQL Error: ${data['errors'][0]['message']}');
      }

      final rooms = data['data']?['rooms'] as List?;

      if (rooms == null || rooms.isEmpty) {
        throw Exception('Room not found. Please check the code and try again.');
      }

      // Update room status to active when joining
      await _updateRoomStatus(roomId, accessToken);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CheckFlipGameScreen(
            boardSize: 4,
            roomId: roomId,
            playerColor: 'black',
            isOnline: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _updateRoomStatus(String roomId, String accessToken) async {
    try {
      final mutation = '''
        mutation UpdateRoomStatus(\$roomId: String!) {
          update_rooms(
            where: {room_id: {_eq: \$roomId}},
            _set: {status: "active"}
          ) {
            affected_rows
          }
        }
      ''';

      await http.post(
        Uri.parse(nhostClient.gqlEndpointUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'query': mutation,
          'variables': {'roomId': roomId},
        }),
      );
    } catch (e) {
      print('Failed to update room status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: -50,
              left: -80,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.login, size: 300, color: AppColors.whiteText),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -70,
              child: Opacity(
                opacity: 0.05,
                child: Text(
                  '♞',
                  style: TextStyle(fontSize: 280, color: AppColors.whiteText),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.whiteText,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Join Room',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon with gradient
                                Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9C27B0),
                                        Color(0xFFE91E63),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF9C27B0,
                                        ).withOpacity(0.5),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.login,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Title
                                const Text(
                                  'Join a Room',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter the room code to join',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.whiteText.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 50),

                                // Room Code Input
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  child: TextFormField(
                                    controller: _roomCodeCtrl,
                                    style: const TextStyle(
                                      color: AppColors.whiteText,
                                      fontSize: 18,
                                      letterSpacing: 2,
                                    ),
                                    textAlign: TextAlign.center,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      labelText: 'Room Code',
                                      labelStyle: TextStyle(
                                        color: AppColors.whiteText.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                      hintText: 'XXXX-XXXX',
                                      hintStyle: TextStyle(
                                        color: AppColors.whiteText.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.whiteText
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF9C27B0),
                                          width: 2,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.vpn_key,
                                        color: AppColors.whiteText.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Room code is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Join Button
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isJoining ? null : _joinRoom,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9C27B0),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      shadowColor: const Color(
                                        0xFF9C27B0,
                                      ).withOpacity(0.5),
                                    ),
                                    child: _isJoining
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'JOIN ROOM',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Info text
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.whiteText.withOpacity(
                                          0.7,
                                        ),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'You will play as Black. Ask your friend for the room code.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.whiteText
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
