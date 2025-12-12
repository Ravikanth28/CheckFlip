import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/piece.dart';
import '../models/game_state.dart';
import '../models/board_position.dart';
import '../logic/movement_rules.dart';
import 'package:nhost_dart/nhost_dart.dart';
import '../main.dart';
import '../widgets/piece_card.dart';
import '../widgets/game_dialog.dart';
import '../utils/app_colors.dart';

class CheckFlipGameScreen extends StatefulWidget {
  final int boardSize;
  final String? roomId;
  final String? playerColor;
  final bool isOnline;

  const CheckFlipGameScreen({
    Key? key,
    required this.boardSize,
    this.roomId,
    this.playerColor,
    this.isOnline = false,
  }) : super(key: key);

  @override
  State<CheckFlipGameScreen> createState() => _CheckFlipGameScreenState();
}

class _CheckFlipGameScreenState extends State<CheckFlipGameScreen> {
  late GameState gameState;
  BoardPosition? selectedPosition;
  List<BoardPosition> validMoves = [];
  bool gameStarted = false;

  // Online multiplayer variables
  int lastMoveNumber = 0;
  Timer? _pollTimer;
  bool _isMyTurn = false;

  @override
  void initState() {
    super.initState();

    // For online play, use room ID as seed so both players get same board
    int? seed;
    if (widget.isOnline && widget.roomId != null) {
      seed = widget.roomId.hashCode;
    }

    gameState = GameState.initial(widget.boardSize, seed: seed);
    _setupInitialBoard();

    // Initialize online multiplayer
    if (widget.isOnline) {
      _isMyTurn = widget.playerColor == 'red'; // Creator (Red) goes first
      _startPolling();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _pollForMoves();
    });
  }

  Future<void> _pollForMoves() async {
    if (!widget.isOnline || widget.roomId == null) return;

    try {
      final accessToken = nhostClient.auth.accessToken;
      if (accessToken == null) return;

      const query = r'''
        query GetMoves($roomId: String!, $afterMove: Int!) {
          game_moves(
            where: {room_id: {_eq: $roomId}, move_number: {_gt: $afterMove}},
            order_by: {move_number: asc}
          ) {
            move_number
            player_color
            move_type
            from_row
            from_col
            to_row
            to_col
          }
        }
      ''';

      final response = await http.post(
        Uri.parse(nhostClient.gqlEndpointUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'query': query,
          'variables': {'roomId': widget.roomId, 'afterMove': lastMoveNumber},
        }),
      );

      final data = json.decode(response.body);
      final moves = data['data']?['game_moves'] as List?;

      if (moves != null && moves.isNotEmpty) {
        for (var move in moves) {
          final playerColor = move['player_color'] as String;
          if (playerColor != widget.playerColor) {
            _applyOpponentMove(move);
          }
          lastMoveNumber = move['move_number'] as int;
        }
      }
    } catch (e) {
      // Silently handle polling errors
    }
  }

  void _applyOpponentMove(Map<String, dynamic> move) {
    final moveType = move['move_type'] as String;

    if (moveType == 'reveal') {
      setState(() {
        for (var pos in gameState.board.getAllPositions()) {
          final piece = gameState.board.getPiece(pos);
          if (piece != null && piece.isFaceDown) {
            gameState.board.setPiece(pos, piece.copyWith(isFaceDown: false));
          }
        }
        gameStarted = true;
      });
    } else if (moveType == 'move' || moveType == 'capture') {
      final from = BoardPosition(
        move['from_row'] as int,
        move['from_col'] as int,
      );
      final to = BoardPosition(move['to_row'] as int, move['to_col'] as int);

      final piece = gameState.board.getPiece(from);
      if (piece != null) {
        final captured = gameState.board.getPiece(to);
        if (captured != null) {
          if (captured.color == PieceColor.red) {
            gameState.redDiscard.add(captured);
          } else {
            gameState.blackDiscard.add(captured);
          }
        }

        if (MovementRules.willPawnBlock(to, piece, gameState.board)) {
          gameState.board.setPiece(
            to,
            piece.copyWith(isFaceDown: true, isBlocked: true),
          );
        } else {
          gameState.board.setPiece(to, piece);
        }

        gameState.board.removePiece(from);
        gameState.switchPlayer();

        setState(() {
          _isMyTurn = true;
        });
      }
    }
  }

  void _setupInitialBoard() {
    int redCount = 0;
    int blackCount = 0;

    // For a 4x4 board with 2 rows each:
    // Row 0: Red pieces (4 pieces)
    // Row 1: Red pieces (4 pieces)
    // Row 2: Black pieces (4 pieces)
    // Row 3: Black pieces (4 pieces)
    // NO EMPTY SPACE - pieces can capture forward

    final rowsPerSide = 2;

    // Place red pieces in top 2 rows
    for (int row = 0; row < rowsPerSide; row++) {
      for (int col = 0; col < widget.boardSize; col++) {
        if (redCount < gameState.redDeck.length) {
          final pos = BoardPosition(row, col);
          final piece = gameState.redDeck[redCount].copyWith(isFaceDown: true);
          gameState.board.setPiece(pos, piece);
          redCount++;
        }
      }
    }

    // Place black pieces in bottom 2 rows
    for (
      int row = widget.boardSize - rowsPerSide;
      row < widget.boardSize;
      row++
    ) {
      for (int col = 0; col < widget.boardSize; col++) {
        if (blackCount < gameState.blackDeck.length) {
          final pos = BoardPosition(row, col);
          final piece = gameState.blackDeck[blackCount].copyWith(
            isFaceDown: true,
          );
          gameState.board.setPiece(pos, piece);
          blackCount++;
        }
      }
    }
  }

  void _revealAllCards() async {
    setState(() {
      for (var pos in gameState.board.getAllPositions()) {
        final piece = gameState.board.getPiece(pos);
        if (piece != null && piece.isFaceDown) {
          gameState.board.setPiece(pos, piece.copyWith(isFaceDown: false));
        }
      }
      gameStarted = true;
    });

    if (widget.isOnline && widget.roomId != null) {
      await _insertMove('reveal', null, null);
    }
  }

  void _onSquareTap(BoardPosition pos) {
    if (!gameStarted) return;
    if (widget.isOnline && !_isMyTurn) return;

    final piece = gameState.board.getPiece(pos);

    if (selectedPosition == null) {
      if (piece != null && !piece.isFaceDown) {
        if (widget.isOnline) {
          final myColor = widget.playerColor == 'red'
              ? PieceColor.red
              : PieceColor.black;
          if (piece.color != myColor) return;
        }

        if (!widget.isOnline && piece.color != gameState.currentPlayer) return;

        setState(() {
          selectedPosition = pos;
          validMoves = MovementRules.getValidMoves(pos, piece, gameState.board);
        });
      }
    } else {
      if (validMoves.contains(pos)) {
        _movePiece(selectedPosition!, pos);
      }
      setState(() {
        selectedPosition = null;
        validMoves = [];
      });
    }
  }

  void _movePiece(BoardPosition from, BoardPosition to) async {
    final piece = gameState.board.getPiece(from)!;
    final captured = gameState.board.getPiece(to);

    if (captured != null) {
      if (captured.color == PieceColor.red) {
        gameState.redDiscard.add(captured);
      } else {
        gameState.blackDiscard.add(captured);
      }
    }

    if (MovementRules.willPawnBlock(to, piece, gameState.board)) {
      gameState.board.setPiece(
        to,
        piece.copyWith(isFaceDown: true, isBlocked: true),
      );
    } else {
      gameState.board.setPiece(to, piece);
    }

    gameState.board.removePiece(from);
    gameState.switchPlayer();

    if (widget.isOnline && widget.roomId != null) {
      await _insertMove(captured != null ? 'capture' : 'move', from, to);
      setState(() {
        _isMyTurn = false;
      });
    }

    if (gameState.hasWon(
      gameState.currentPlayer == PieceColor.red
          ? PieceColor.black
          : PieceColor.red,
    )) {
      _showVictoryDialog();
    }

    setState(() {});
  }

  Future<void> _insertMove(
    String moveType,
    BoardPosition? from,
    BoardPosition? to,
  ) async {
    try {
      final accessToken = nhostClient.auth.accessToken;
      if (accessToken == null) return;

      lastMoveNumber++;

      const mutation = r'''
        mutation InsertMove(
          $roomId: String!,
          $moveNumber: Int!,
          $playerColor: String!,
          $moveType: String!,
          $fromRow: Int,
          $fromCol: Int,
          $toRow: Int,
          $toCol: Int
        ) {
          insert_game_moves_one(object: {
            room_id: $roomId,
            move_number: $moveNumber,
            player_color: $playerColor,
            move_type: $moveType,
            from_row: $fromRow,
            from_col: $fromCol,
            to_row: $toRow,
            to_col: $toCol
          }) {
            id
          }
        }
      ''';

      await http.post(
        Uri.parse(nhostClient.gqlEndpointUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'query': mutation,
          'variables': {
            'roomId': widget.roomId,
            'moveNumber': lastMoveNumber,
            'playerColor': widget.playerColor,
            'moveType': moveType,
            'fromRow': from?.row,
            'fromCol': from?.col,
            'toRow': to?.row,
            'toCol': to?.col,
          },
        }),
      );
    } catch (e) {
      // Silently handle insert errors
    }
  }

  void _showVictoryDialog() {
    final winner = gameState.currentPlayer == PieceColor.red ? 'Black' : 'Red';
    GameDialog.show(
      context,
      '$winner Wins!\nCongratulations!',
      onConfirm: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we need to flip the board
    // Red player: Red at bottom (normal)
    // Black player: Black at bottom (flipped)
    final bool flipBoard = widget.isOnline && widget.playerColor == 'black';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.isOnline
              ? 'CheckFlip Online - ${widget.playerColor?.toUpperCase()}'
              : 'CheckFlip ${widget.boardSize}×${widget.boardSize}',
          style: const TextStyle(color: AppColors.whiteText),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteText),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Top panel (opponent for current player)
            _buildPlayerPanel(
              flipBoard ? PieceColor.black : PieceColor.red,
              isTop: true,
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.boardDark,
                      border: Border.all(
                        color: AppColors.boardBorder,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _buildBoard(flipBoard),
                  ),
                ),
              ),
            ),
            // Bottom panel (current player)
            _buildPlayerPanel(
              flipBoard ? PieceColor.red : PieceColor.black,
              isTop: false,
            ),
            if (!gameStarted)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _revealAllCards,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Reveal All Cards',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard([bool flip = false]) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.boardSize,
      ),
      itemCount: widget.boardSize * widget.boardSize,
      itemBuilder: (context, index) {
        // Flip the board for black player
        final displayIndex = flip
            ? (widget.boardSize * widget.boardSize - 1 - index)
            : index;

        final row = displayIndex ~/ widget.boardSize;
        final col = displayIndex % widget.boardSize;
        final pos = BoardPosition(row, col);
        final piece = gameState.board.getPiece(pos);
        final isSelected = selectedPosition == pos;
        final isValidMove = validMoves.contains(pos);

        return PieceCard(
          piece: piece,
          isSelected: isSelected,
          isValidMove: isValidMove,
          fromPosition: isValidMove ? selectedPosition : null,
          toPosition: isValidMove ? pos : null,
          onTap: () => _onSquareTap(pos),
        );
      },
    );
  }

  Widget _buildPlayerPanel(PieceColor color, {required bool isTop}) {
    final isCurrentPlayer = gameState.currentPlayer == color;
    final deck = gameState.getDeck(color);
    final discard = gameState.getDiscard(color);
    final isMyColor =
        widget.isOnline &&
        ((widget.playerColor == 'red' && color == PieceColor.red) ||
            (widget.playerColor == 'black' && color == PieceColor.black));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.green.shade100 : Colors.grey.shade200,
        border: Border(
          bottom: isTop
              ? BorderSide(color: Colors.brown.shade300, width: 2)
              : BorderSide.none,
          top: !isTop
              ? BorderSide(color: Colors.brown.shade300, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                color == PieceColor.red ? 'RED' : 'BLACK',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color == PieceColor.red ? Colors.red : Colors.black,
                ),
              ),
              if (widget.isOnline && isMyColor)
                Text(
                  'YOU',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          Text('Deck: ${deck.length}'),
          Text('Captured: ${discard.length}'),
          if (widget.isOnline && isMyColor && _isMyTurn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'YOUR TURN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else if (isCurrentPlayer)
            const Icon(Icons.arrow_forward, color: Colors.green),
        ],
      ),
    );
  }
}
