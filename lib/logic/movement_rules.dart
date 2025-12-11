import '../models/piece.dart';
import '../models/board_position.dart';
import '../models/game_board.dart';

class MovementRules {
  static List<BoardPosition> getValidMoves(
    BoardPosition from,
    Piece piece,
    GameBoard board,
  ) {
    if (piece.isFaceDown || piece.isBlocked) {
      return [];
    }

    switch (piece.type) {
      case PieceType.king:
        return _getKingMoves(from, piece, board);
      case PieceType.queen:
        return _getQueenMoves(from, piece, board);
      case PieceType.rook:
        return _getRookMoves(from, piece, board);
      case PieceType.bishop:
        return _getBishopMoves(from, piece, board);
      case PieceType.knight:
        return _getKnightMoves(from, piece, board);
      case PieceType.pawn:
        return _getPawnMoves(from, piece, board);
      case PieceType.joker:
        return []; // Joker cannot move
    }
  }

  static List<BoardPosition> _getKingMoves(
    BoardPosition from,
    Piece piece,
    GameBoard board,
  ) {
    List<BoardPosition> moves = [];
    final directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];

    for (var dir in directions) {
      final newPos = BoardPosition(from.row + dir[0], from.col + dir[1]);
      if (_isValidMove(newPos, piece, board)) {
        moves.add(newPos);
      }
    }
    return moves;
  }

  static List<BoardPosition> _getQueenMoves(
    BoardPosition from,
    Piece piece,
    GameBoard board,
  ) {
    // Queen = Rook + Bishop
    return [
      ..._getRookMoves(from, piece, board),
      ..._getBishopMoves(from, piece, board),
    ];
  }

  static List<BoardPosition> _getRookMoves(
    BoardPosition from,
    Piece piece,
    GameBoard board,
  ) {
    List<BoardPosition> moves = [];
    final directions = [
      [-1, 0], // Up
      [1, 0], // Down
      [0, -1], // Left
      [0, 1], // Right
    ];

    for (var dir in directions) {
      moves.addAll(_getLineMoves(from, dir[0], dir[1], piece, board));
    }
    return moves;
  }

  static List<BoardPosition> _getBishopMoves(
    BoardPosition from,
    Piece piece,
    GameBoard board,
  ) {
    List<BoardPosition> moves = [];
    final directions = [
      [-1, -1], // Up-Left
      [-1, 1], // Up-Right
      [1, -1], // Down-Left
      [1, 1], // Down-Right
    ];

    for (var dir in directions) {
      moves.addAll(_getLineMoves(from, dir[0], dir[1], piece, board));
    }
    return moves;
  }

  static List<BoardPosition> _getKnightMoves(
    BoardPosition from,
    Piece piece,
    GameBoard board,
  ) {
    List<BoardPosition> moves = [];
    final knightMoves = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1],
    ];

    for (var move in knightMoves) {
      final newPos = BoardPosition(from.row + move[0], from.col + move[1]);
      if (_isValidMove(newPos, piece, board)) {
        moves.add(newPos);
      }
    }
    return moves;
  }

  static List<BoardPosition> _getPawnMoves(
    BoardPosition from,
    Piece piece,
    GameBoard board,
  ) {
    List<BoardPosition> moves = [];
    // Pawns move forward based on color
    // Red moves up (decreasing row), Black moves down (increasing row)
    final direction = piece.color == PieceColor.red ? -1 : 1;

    // Forward move or capture
    final forward = BoardPosition(from.row + direction, from.col);
    if (forward.isValid(board.size)) {
      final targetPiece = board.getPiece(forward);
      if (targetPiece == null) {
        // Empty - can move
        moves.add(forward);
      } else if (targetPiece.color != piece.color) {
        // Enemy - can capture forward
        moves.add(forward);
      }
    }

    // Diagonal captures
    final diagonalLeft = BoardPosition(from.row + direction, from.col - 1);
    final diagonalRight = BoardPosition(from.row + direction, from.col + 1);

    if (_canCapture(diagonalLeft, piece, board)) {
      moves.add(diagonalLeft);
    }
    if (_canCapture(diagonalRight, piece, board)) {
      moves.add(diagonalRight);
    }

    return moves;
  }

  static List<BoardPosition> _getLineMoves(
    BoardPosition from,
    int rowDir,
    int colDir,
    Piece piece,
    GameBoard board,
  ) {
    List<BoardPosition> moves = [];
    int row = from.row + rowDir;
    int col = from.col + colDir;

    while (row >= 0 && row < board.size && col >= 0 && col < board.size) {
      final pos = BoardPosition(row, col);
      final targetPiece = board.getPiece(pos);

      if (targetPiece == null) {
        moves.add(pos);
      } else {
        if (targetPiece.color != piece.color) {
          moves.add(pos); // Can capture
        }
        break; // Stop at any piece
      }

      row += rowDir;
      col += colDir;
    }

    return moves;
  }

  static bool _isValidMove(BoardPosition pos, Piece piece, GameBoard board) {
    if (!pos.isValid(board.size)) return false;

    final targetPiece = board.getPiece(pos);
    if (targetPiece == null) return true;
    if (targetPiece.color != piece.color) return true; // Can capture

    return false;
  }

  static bool _canCapture(BoardPosition pos, Piece piece, GameBoard board) {
    if (!pos.isValid(board.size)) return false;

    final targetPiece = board.getPiece(pos);
    return targetPiece != null && targetPiece.color != piece.color;
  }

  static bool willPawnBlock(BoardPosition to, Piece piece, GameBoard board) {
    if (piece.type != PieceType.pawn) return false;

    // Check if pawn reaches final row
    if (piece.color == PieceColor.red && to.row == 0) return true;
    if (piece.color == PieceColor.black && to.row == board.size - 1)
      return true;

    return false;
  }
}
