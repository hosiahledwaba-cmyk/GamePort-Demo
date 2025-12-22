import '../models/pawn.dart';
import '../models/player.dart';

class AiController {
  /// Returns the index of the best pawn to move (0-3), or null if no move is possible.
  Pawn? chooseBestMove(
    Player aiPlayer,
    List<Player> allPlayers,
    int diceValue,
  ) {
    List<Pawn> movablePawns = aiPlayer.pawns.where((p) {
      if (p.isHome) return false;
      if (p.inBase && diceValue != 6) return false;
      // Note: Add collision check logic here in real game (e.g. can't land on own pawn)
      return true;
    }).toList();

    if (movablePawns.isEmpty) return null;

    // Scoring System
    Pawn? bestPawn;
    int bestScore = -1000;

    for (var pawn in movablePawns) {
      int score = 0;

      // 1. Priority: Move out of base
      if (pawn.inBase && diceValue == 6) {
        score += 100;
      }

      // 2. Priority: Capture opponent (Simplified logic)
      // Calculate future position and check if it lands on an opponent
      // int projectedStep = pawn.stepIndex + (pawn.inBase ? 1 : diceValue);
      // if (projectedStep lands on opponent) score += 50;

      // 3. Priority: Reach Home
      if (pawn.stepIndex + diceValue == 57) {
        score += 200;
      }

      // 4. Priority: Advance closest to home
      score += pawn.stepIndex;

      if (score > bestScore) {
        bestScore = score;
        bestPawn = pawn;
      }
    }

    return bestPawn;
  }
}
