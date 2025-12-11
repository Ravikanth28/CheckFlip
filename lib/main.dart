import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nhost_dart/nhost_dart.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import 'package:nhost_flutter_graphql/nhost_flutter_graphql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/login_page.dart';
import 'screens/home_screen.dart';
import 'screens/signup_page.dart';
import 'screens/game_mode_selection_screen.dart';
import 'screens/bot_game_screen.dart';
import 'screens/room_selection_screen.dart';
import 'screens/create_room_screen.dart';
import 'screens/join_room_screen.dart';
import 'screens/offline_game_screen.dart';
import 'screens/board_size_selection_screen.dart';
import 'screens/checkflip_game_screen.dart';

// Global instances
final secureStorage = FlutterSecureStorage();
late NhostClient nhostClient;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final subdomain = dotenv.env['NHOST_SUBDOMAIN'] ?? 'your-subdomain';
  final region = dotenv.env['NHOST_REGION'] ?? 'ap-south-1';

  nhostClient = NhostClient(
    subdomain: Subdomain(subdomain: subdomain, region: region),
  );

  runApp(MyApp(nhostClient: nhostClient));
}

class MyApp extends StatelessWidget {
  final NhostClient nhostClient;
  const MyApp({Key? key, required this.nhostClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NhostGraphQLProvider(
      nhostClient: nhostClient,
      child: NhostAuthProvider(
        auth: nhostClient.auth,
        child: MaterialApp(
          title: 'Antigravity - Nhost Flutter',
          theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(
              nhostClient: nhostClient,
              secureStorage: secureStorage,
            ),
            '/signup': (context) => SignUpPage(
              nhostClient: nhostClient,
              secureStorage: secureStorage,
            ),
            '/home': (context) => HomeScreen(
              nhostClient: nhostClient,
              secureStorage: secureStorage,
            ),
            '/game-modes': (context) => const GameModeSelectionScreen(),
            '/bot-game': (context) => const BotGameScreen(),
            '/offline-game': (context) => const OfflineGameScreen(),
            '/board-size-selection': (context) =>
                const BoardSizeSelectionScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/game') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => CheckFlipGameScreen(
                  boardSize: args['boardSize'] as int,
                  roomId: args['roomId'] as String?,
                  playerColor: args['playerColor'] as String?,
                  isOnline: args['isOnline'] as bool? ?? false,
                ),
              );
            }
            if (settings.name == '/room-game') {
              return MaterialPageRoute(
                builder: (context) =>
                    RoomSelectionScreen(nhostClient: nhostClient),
              );
            }
            if (settings.name == '/create-room') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => CreateRoomScreen(
                  nhostClient:
                      args?['nhostClient'] as NhostClient? ?? nhostClient,
                ),
              );
            }
            if (settings.name == '/join-room') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => JoinRoomScreen(
                  nhostClient:
                      args?['nhostClient'] as NhostClient? ?? nhostClient,
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
