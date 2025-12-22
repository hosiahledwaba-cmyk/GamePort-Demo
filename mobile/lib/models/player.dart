import 'dart:ui';
import 'pawn.dart';

enum PlayerType { human, ai }

class Player {
  final int id; // 0, 1, 2, 3
  final Color color;
  final PlayerType type;
  final List<Pawn> pawns;
  int completedPawns = 0;

  Player({required this.id, required this.color, required this.type})
    : pawns = List.generate(
        4,
        (index) => Pawn(id: index, playerId: id, color: color),
      );

  bool get hasWon => completedPawns == 4;
}
