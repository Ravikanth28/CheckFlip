import 'package:flutter/material.dart';

class GameModeSelectionScreen extends StatelessWidget {
  const GameModeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckFlip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.games_outlined,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Choose Game Mode',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),
                _buildGameModeCard(
                  context,
                  icon: Icons.smart_toy_outlined,
                  title: 'Bot',
                  description: 'Play against AI',
                  color: Colors.purple,
                  onTap: () => Navigator.of(context).pushNamed('/bot-game'),
                ),
                const SizedBox(height: 20),
                _buildGameModeCard(
                  context,
                  icon: Icons.wifi,
                  title: 'Room',
                  description: 'Play online with friends',
                  color: Colors.green,
                  onTap: () => Navigator.of(context).pushNamed('/room-game'),
                ),
                const SizedBox(height: 20),
                _buildGameModeCard(
                  context,
                  icon: Icons.people_outline,
                  title: 'Offline',
                  description: '2 players on same device',
                  color: Colors.orange,
                  onTap: () => Navigator.of(context).pushNamed('/offline-game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
