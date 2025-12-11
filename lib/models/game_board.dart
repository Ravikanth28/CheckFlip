import 'piece.dart';
import 'board_position.dart';

class GameBoard {
  final int size;
  final Map<BoardPosition, Piece?> _grid;

  GameBoard(this.size) : _grid = {};

  Piece? getPiece(BoardPosition pos) => _grid[pos];

  void setPiece(BoardPosition pos, Piece? piece) {
    _grid[pos] = piece;
  }

  void removePiece(BoardPosition pos) {
    _grid.remove(pos);
  }

  bool isEmpty(BoardPosition pos) => _grid[pos] == null;

  List<BoardPosition> getAllPositions() {
    List<BoardPosition> positions = [];
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        positions.add(BoardPosition(row, col));
      }
    }
    return positions;
  }

  List<BoardPosition> getEmptyPositions() {
    return getAllPositions().where((pos) => isEmpty(pos)).toList();
  }

  List<BoardPosition> getPiecesOfColor(PieceColor color) {
    return _grid.entries
        .where((entry) => entry.value != null && entry.value!.color == color)
        .map((entry) => entry.key)
        .toList();
  }

  Map<BoardPosition, Piece?> get grid => Map.unmodifiable(_grid);
}
