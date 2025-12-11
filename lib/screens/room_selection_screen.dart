import 'package:flutter/material.dart';
import 'package:nhost_dart/nhost_dart.dart';

class RoomSelectionScreen extends StatelessWidget {
  final NhostClient nhostClient;

  const RoomSelectionScreen({
    Key? key,
    required this.nhostClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Mode'),
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
            colors: [Colors.green.shade100, Colors.green.shade50],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi,
                  size: 100,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Online Room',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Play with friends online',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                _buildOptionCard(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Create Room',
                  description: 'Start a new game room',
                  color: Colors.blue,
                  onTap: () => Navigator.of(context).pushNamed(
                    '/create-room',
                    arguments: {'nhostClient': nhostClient},
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionCard(
                  context,
                  icon: Icons.login,
                  title: 'Join Room',
                  description: 'Enter a room code',
                  color: Colors.purple,
                  onTap: () => Navigator.of(context).pushNamed(
                    '/join-room',
                    arguments: {'nhostClient': nhostClient},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
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
                          fontSize: 22,
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
