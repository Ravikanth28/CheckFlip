import 'piece.dart';
import 'game_board.dart';
import 'board_position.dart';
import 'dart:math';

class GameState {
  final GameBoard board;
  final List<Piece> redDeck;
  final List<Piece> blackDeck;
  final List<Piece> redDiscard;
  final List<Piece> blackDiscard;
  PieceColor currentPlayer;
  int moveCount;
  
  // Joker tracking
  BoardPosition? redJokerPosition;
  BoardPosition? blackJokerPosition;
  int? redJokerTurnsLeft;
  int? blackJokerTurnsLeft;

  GameState({
    required this.board,
    required this.redDeck,
    required this.blackDeck,
    required this.redDiscard,
    required this.blackDiscard,
    this.currentPlayer = PieceColor.red,
    this.moveCount = 0,
    this.redJokerPosition,
    this.blackJokerPosition,
    this.redJokerTurnsLeft,
    this.blackJokerTurnsLeft,
  });

  factory GameState.initial(int boardSize, {int? seed}) {
    return GameState(
      board: GameBoard(boardSize),
      redDeck: _createDeck(PieceColor.red, seed: seed),
      blackDeck: _createDeck(PieceColor.black, seed: seed),
      redDiscard: [],
      blackDiscard: [],
    );
  }

  static List<Piece> _createDeck(PieceColor color, {int? seed}) {
    List<Piece> deck = [];
    
    // 2 Kings
    deck.addAll(List.generate(2, (_) => Piece(type: PieceType.king, color: color)));
    // 2 Queens
    deck.addAll(List.generate(2, (_) => Piece(type: PieceType.queen, color: color)));
    // 2 Rooks
    deck.addAll(List.generate(2, (_) => Piece(type: PieceType.rook, color: color)));
    // 2 Bishops
    deck.addAll(List.generate(2, (_) => Piece(type: PieceType.bishop, color: color)));
    // 2 Knights
    deck.addAll(List.generate(2, (_) => Piece(type: PieceType.knight, color: color)));
    // 16 Pawns
    deck.addAll(List.generate(16, (_) => Piece(type: PieceType.pawn, color: color)));
    // 1 Joker
    deck.add(Piece(type: PieceType.joker, color: color));
    
    // Shuffle with seed for online play, or random for offline
    deck.shuffle(seed != null ? Random(seed) : Random());
    
    return deck;
  }

  void switchPlayer() {
    currentPlayer = currentPlayer == PieceColor.red ? PieceColor.black : PieceColor.red;
    moveCount++;
    
    // Decrement Joker turns
    if (currentPlayer == PieceColor.red && redJokerTurnsLeft != null) {
      redJokerTurnsLeft = redJokerTurnsLeft! - 1;
      if (redJokerTurnsLeft! <= 0) {
        redJokerTurnsLeft = null;
      }
    } else if (currentPlayer == PieceColor.black && blackJokerTurnsLeft != null) {
      blackJokerTurnsLeft = blackJokerTurnsLeft! - 1;
      if (blackJokerTurnsLeft! <= 0) {
        blackJokerTurnsLeft = null;
      }
    }
  }

  List<Piece> getDeck(PieceColor color) {
    return color == PieceColor.red ? redDeck : blackDeck;
  }

  List<Piece> getDiscard(PieceColor color) {
    return color == PieceColor.red ? redDiscard : blackDiscard;
  }

  bool hasWon(PieceColor color) {
    final opponent = color == PieceColor.red ? PieceColor.black : PieceColor.red;
    
    // Check if both opponent kings are captured
    int opponentKingsOnBoard = 0;
    for (var entry in board.grid.entries) {
      if (entry.value != null && 
          entry.value!.color == opponent && 
          entry.value!.type == PieceType.king) {
        opponentKingsOnBoard++;
      }
    }
    
    if (opponentKingsOnBoard == 0) {
      // Check if opponent has kings in deck
      final opponentDeck = getDeck(opponent);
      final kingsInDeck = opponentDeck.where((p) => p.type == PieceType.king).length;
      if (kingsInDeck == 0) {
        return true; // Both kings captured
      }
    }
    
    // Check for total domination
    final opponentPieces = board.getPiecesOfColor(opponent);
    final opponentDeckEmpty = getDeck(opponent).isEmpty;
    if (opponentPieces.isEmpty && opponentDeckEmpty) {
      return true;
    }
    
    return false;
  }
}
