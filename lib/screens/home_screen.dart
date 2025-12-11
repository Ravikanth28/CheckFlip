import 'package:flutter/material.dart';
import 'package:nhost_dart/nhost_dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/welcome_popup.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcomePopup = true;

  @override
  void initState() {
    super.initState();
    // Show welcome popup, then navigate to game modes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _showWelcomePopup) {
        _showWelcome();
      }
    });
  }

  void _showWelcome() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WelcomePopup(
        onDismiss: () {
          Navigator.of(context).pop();
          // Navigate to game mode selection
          Navigator.of(context).pushReplacementNamed('/game-modes');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This screen is just a transition point
    // The welcome popup will show and then navigate to game modes
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
