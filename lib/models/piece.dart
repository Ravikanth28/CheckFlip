enum PieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn,
  joker,
}

enum PieceColor {
  red,
  black,
}

class Piece {
  final PieceType type;
  final PieceColor color;
  bool isFaceDown;
  bool isBlocked; // For pawns that reached the border

  Piece({
    required this.type,
    required this.color,
    this.isFaceDown = false,
    this.isBlocked = false,
  });

  Piece copyWith({
    PieceType? type,
    PieceColor? color,
    bool? isFaceDown,
    bool? isBlocked,
  }) {
    return Piece(
      type: type ?? this.type,
      color: color ?? this.color,
      isFaceDown: isFaceDown ?? this.isFaceDown,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  String get symbol {
    if (isFaceDown) return '?';
    switch (type) {
      case PieceType.king:
        return '♔';
      case PieceType.queen:
        return '♕';
      case PieceType.rook:
        return '♖';
      case PieceType.bishop:
        return '♗';
      case PieceType.knight:
        return '♘';
      case PieceType.pawn:
        return '♙';
      case PieceType.joker:
        return 'J';
    }
  }
}
