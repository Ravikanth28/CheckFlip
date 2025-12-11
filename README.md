# CheckFlip - Online Multiplayer Chess Card Game

A Flutter-based chess variant card game with online multiplayer capabilities using Nhost backend.

## Features

- **Online Multiplayer**: Real-time room-based gameplay with move synchronization
- **Chess-like Mechanics**: All standard chess pieces with proper movement rules
- **Authentication**: Secure login/signup with Nhost
- **Room System**: Create or join game rooms with unique IDs
- **Turn-based Gameplay**: Proper turn management and color assignment

## Game Pieces

- King (♔/♚) - Moves 1 square in any direction
- Queen (♕/♛) - Moves any distance straight or diagonal
- Rook (♖/♜) - Moves any distance horizontally or vertically
- Bishop (♗/♝) - Moves any distance diagonally
- Knight (♘/♞) - Moves in L-shape
- Pawn (♙/♟) - Moves forward, captures forward or diagonally
- Joker (J) - Cannot move

## Setup

### Prerequisites

- Flutter SDK
- Nhost account

### Configuration

1. Create a `.env` file in the project root:
```
NHOST_SUBDOMAIN=your-subdomain
NHOST_REGION=your-region
```

2. Set up database tables using the SQL files:
   - `database.sql` - Main tables
   - `database_rooms.sql` - Room system
   - `database_game_sync.sql` - Move synchronization

3. Configure Hasura permissions for `user` role on all tables

### Installation

```bash
flutter pub get
flutter run
```

## How to Play

### Online Multiplayer

1. **Create Room**: 
   - Login → Game Modes → Room → Create Room
   - Share the 8-character room ID with your opponent

2. **Join Room**:
   - Login → Game Modes → Room → Join Room
   - Enter the room ID

3. **Gameplay**:
   - Creator plays as RED (bottom)
   - Joiner plays as BLACK (bottom)
   - Click "Reveal All Cards" to start
   - Take turns moving pieces
   - Win by capturing both enemy kings

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Nhost (PostgreSQL + Hasura GraphQL)
- **Authentication**: Nhost Auth
- **Real-time Sync**: GraphQL polling (1-second intervals)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Game data models
│   ├── piece.dart
│   ├── game_state.dart
│   ├── game_board.dart
│   └── board_position.dart
├── logic/                    # Game logic
│   └── movement_rules.dart
└── screens/                  # UI screens
    ├── login_page.dart
    ├── signup_page.dart
    ├── home_screen.dart
    ├── game_mode_selection_screen.dart
    ├── create_room_screen.dart
    ├── join_room_screen.dart
    └── checkflip_game_screen.dart
```

## License

MIT
