class BoardPosition {
  final int row;
  final int col;

  const BoardPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';

  bool isValid(int boardSize) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }
}
