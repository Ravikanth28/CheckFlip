import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../utils/app_colors.dart';
import 'checkflip_game_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen>
    with SingleTickerProviderStateMixin {
  late String roomCode;
  bool _isCreating = true;
  bool _opponentJoined = false;
  String? _error;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    roomCode = const Uuid().v4().substring(0, 8).toUpperCase();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _createRoom();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    try {
      // Check if user is authenticated
      if (nhostClient.auth.currentUser == null) {
        throw Exception('Not authenticated. Please log in again.');
      }

      final accessToken = nhostClient.auth.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token. Please log in again.');
      }

      print('Creating room with token: ${accessToken.substring(0, 20)}...');

      final mutation = '''
        mutation CreateRoom(\$roomId: String!) {
          insert_rooms_one(object: {
            room_id: \$roomId,
            status: "waiting"
          }) {
            id
            room_id
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
          'query': mutation,
          'variables': {'roomId': roomCode},
        }),
      );

      print('Create room response: ${response.body}');

      final responseData = json.decode(response.body);

      if (responseData['errors'] != null) {
        throw Exception('GraphQL Error: ${responseData['errors']}');
      }

      if (response.statusCode == 200 && responseData['data'] != null) {
        setState(() => _isCreating = false);
        _listenForOpponent();
      } else {
        throw Exception('Failed to create room: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isCreating = false;
      });
    }
  }

  void _listenForOpponent() {
    // Poll for opponent joining (in a real app, use subscriptions)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _checkOpponentJoined();
      }
    });
  }

  Future<void> _checkOpponentJoined() async {
    try {
      final accessToken = nhostClient.auth.accessToken;
      if (accessToken == null) return;

      final query = '''
        query CheckRoom(\$roomId: String!) {
          rooms(where: {room_id: {_eq: \$roomId}}) {
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
          'variables': {'roomId': roomCode},
        }),
      );

      final data = json.decode(response.body);
      final rooms = data['data']?['rooms'] as List?;

      if (rooms != null && rooms.isNotEmpty) {
        final status = rooms[0]['status'];
        if (status == 'active') {
          setState(() => _opponentJoined = true);
          _startGame();
        } else {
          // Continue polling
          _listenForOpponent();
        }
      }
    } catch (e) {
      // Continue polling even on error
      _listenForOpponent();
    }
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CheckFlipGameScreen(
          boardSize: 4,
          roomId: roomCode,
          playerColor: 'red',
          isOnline: true,
        ),
      ),
    );
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Room code copied!'),
        backgroundColor: AppColors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
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
                      'Create Room',
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isCreating) ...[
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Creating room...',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.whiteText,
                            ),
                          ),
                        ] else if (_error != null) ...[
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Error: $_error',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          // Pulsing icon
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2196F3),
                                    Color(0xFF00BCD4),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2196F3,
                                    ).withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.hourglass_empty,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Title
                          const Text(
                            'Waiting for Opponent',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.whiteText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share this code with your friend',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.whiteText.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 50),

                          // Room Code Display
                          Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.redAccent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.redAccent.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'ROOM CODE',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.whiteText,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  roomCode,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteText,
                                    letterSpacing: 8,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _copyRoomCode,
                                  icon: const Icon(Icons.copy, size: 20),
                                  label: const Text('COPY CODE'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.redAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Info box
                          Container(
                            constraints: const BoxConstraints(maxWidth: 400),
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
                                  color: AppColors.whiteText.withOpacity(0.7),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'You will play as Red. Game starts when opponent joins.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.whiteText.withOpacity(
                                        0.7,
                                      ),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
