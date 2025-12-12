import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../main.dart';

class GameModeSelectionScreen extends StatefulWidget {
  const GameModeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GameModeSelectionScreen> createState() =>
      _GameModeSelectionScreenState();
}

class _GameModeSelectionScreenState extends State<GameModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Background chess pieces
            Positioned(
              top: -80,
              left: -60,
              child: Opacity(
                opacity: 0.03,
                child: Text(
                  '♜',
                  style: TextStyle(fontSize: 300, color: AppColors.whiteText),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -70,
              child: Opacity(
                opacity: 0.03,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CHECKFLIP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteText,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.whiteText,
                          ),
                          onPressed: () async {
                            try {
                              await nhostClient.auth.signOut();
                              // Clear stored credentials
                              await secureStorage.delete(key: 'user_email');
                              await secureStorage.delete(key: 'user_password');
                              await secureStorage.delete(
                                key: 'nhost_access_token',
                              );

                              if (!mounted) return;
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            } catch (e) {
                              print('Logout error: $e');
                            }
                          },
                          tooltip: 'Logout',
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
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title
                                const Text(
                                  'Choose Game Mode',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select how you want to play',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.whiteText.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 50),

                                // Bot Mode
                                _buildGameModeCard(
                                  context,
                                  icon: Icons.smart_toy,
                                  title: 'Bot',
                                  description: 'Play against AI',
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF9C27B0),
                                      Color(0xFFE91E63),
                                    ],
                                  ),
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed('/bot-game'),
                                ),
                                const SizedBox(height: 20),

                                // Room Mode
                                _buildGameModeCard(
                                  context,
                                  icon: Icons.wifi,
                                  title: 'Room',
                                  description: 'Play online with friends',
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00C853),
                                      Color(0xFF00E676),
                                    ],
                                  ),
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed('/room-game'),
                                ),
                                const SizedBox(height: 20),

                                // Offline Mode
                                _buildGameModeCard(
                                  context,
                                  icon: Icons.people,
                                  title: 'Offline',
                                  description: '2 players on same device',
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6F00),
                                      Color(0xFFFFAB00),
                                    ],
                                  ),
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed('/offline-game'),
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

  Widget _buildGameModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 20),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.whiteText.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.whiteText.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
