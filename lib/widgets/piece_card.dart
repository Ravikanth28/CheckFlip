import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/board_position.dart';
import '../utils/app_colors.dart';

class PieceCard extends StatelessWidget {
  final Piece? piece;
  final bool isSelected;
  final bool isValidMove;
  final VoidCallback? onTap;
  final BoardPosition? fromPosition;
  final BoardPosition? toPosition;

  const PieceCard({
    Key? key,
    this.piece,
    this.isSelected = false,
    this.isValidMove = false,
    this.onTap,
    this.fromPosition,
    this.toPosition,
  }) : super(key: key);

  IconData _getDirectionArrow() {
    if (fromPosition == null || toPosition == null) {
      return Icons.circle;
    }

    final rowDiff = toPosition!.row - fromPosition!.row;
    final colDiff = toPosition!.col - fromPosition!.col;

    // Diagonal moves
    if (rowDiff < 0 && colDiff < 0) return Icons.north_west;
    if (rowDiff < 0 && colDiff > 0) return Icons.north_east;
    if (rowDiff > 0 && colDiff < 0) return Icons.south_west;
    if (rowDiff > 0 && colDiff > 0) return Icons.south_east;

    // Straight moves
    if (rowDiff < 0) return Icons.north;
    if (rowDiff > 0) return Icons.south;
    if (colDiff < 0) return Icons.west;
    if (colDiff > 0) return Icons.east;

    return Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isValidMove
              ? AppColors.cardWhite
              : piece != null && !piece!.isFaceDown
              ? AppColors.cardWhite
              : AppColors.boardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.redHighlight
                : isValidMove
                ? AppColors.redAccent.withOpacity(0.5)
                : AppColors.cardBorder,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: (piece != null && !piece!.isFaceDown) || isValidMove
              ? [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isValidMove
              ? Icon(
                  _getDirectionArrow(),
                  color: AppColors.blackPlayer,
                  size: 28,
                )
              : piece != null
              ? (piece!.isFaceDown
                    ? const Icon(
                        Icons.help_outline,
                        color: AppColors.grayText,
                        size: 24,
                      )
                    : Text(
                        piece!.symbol,
                        style: TextStyle(
                          fontSize: 32,
                          color: piece!.color == PieceColor.red
                              ? AppColors.redPlayer
                              : AppColors.blackPlayer,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
              : null,
        ),
      ),
    );
  }
}
