import 'package:flutter/material.dart';
import 'package:nhost_dart/nhost_dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final NhostClient nhostClient;
  final FlutterSecureStorage secureStorage;

  const HomeScreen({
    Key? key,
    required this.nhostClient,
    required this.secureStorage,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

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
            // Chess piece decorations in background
            Positioned(
              bottom: -50,
              left: -30,
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  '♔',
                  style: TextStyle(fontSize: 200, color: AppColors.whiteText),
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -20,
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  '♕',
                  style: TextStyle(fontSize: 180, color: AppColors.whiteText),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 30,
              child: Opacity(
                opacity: 0.08,
                child: Text(
                  '♖',
                  style: TextStyle(fontSize: 150, color: AppColors.whiteText),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo/Title
                        const Text(
                          'CHECKFLIP',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteText,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chess Card Strategy',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.whiteText.withOpacity(0.7),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 80),

                        // START Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/game-modes');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 80,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.redAccent.withOpacity(0.5),
                          ),
                          child: const Text(
                            'START',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
