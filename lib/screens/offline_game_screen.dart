import 'package:flutter/material.dart';

class OfflineGameScreen extends StatefulWidget {
  const OfflineGameScreen({Key? key}) : super(key: key);

  @override
  State<OfflineGameScreen> createState() => _OfflineGameScreenState();
}

class _OfflineGameScreenState extends State<OfflineGameScreen> {
  int currentPlayer = 1;

  void _switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode'),
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
            colors: [Colors.orange.shade100, Colors.orange.shade50],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: currentPlayer == 1 ? Colors.blue : Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    currentPlayer == 1 ? Icons.person : Icons.person_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Player $currentPlayer\'s Turn',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 120,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Offline 2-Player Mode',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Play with a friend on the same device\n\nGame board coming soon!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/board-size-selection');
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
            ),
          ],
        ),
      ),
    );
  }
}
