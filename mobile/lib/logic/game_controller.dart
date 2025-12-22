import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/player.dart';
import '../models/pawn.dart';

enum GamePhase { rolling, moving, anim, win }

class GameController extends ChangeNotifier {
  List<Player> players = [];
  int currentPlayerIndex = 0;
  int currentDiceValue = 1;
  int consecutiveSixes = 0;
  GamePhase phase = GamePhase.rolling;

  // CRITICAL: The Master Lock
  bool _isProcessingTurn = false;

  void startGame(int playerCount) {
    players.clear();
    List<Color> colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];

    // Player 0 is Human
    players.add(Player(id: 0, color: colors[0], type: PlayerType.human));

    // Others are AI
    for (int i = 1; i < playerCount; i++) {
      players.add(Player(id: i, color: colors[i], type: PlayerType.ai));
    }

    currentPlayerIndex = 0;
    consecutiveSixes = 0;
    phase = GamePhase.rolling;
    _isProcessingTurn = false;
    notifyListeners();
  }

  void rollDice() async {
    // 1. Strict Guard Clauses
    if (phase != GamePhase.rolling) return;
    if (_isProcessingTurn) return;

    // 2. Prevent Human from rolling for AI
    if (players[currentPlayerIndex].type != PlayerType.human &&
        players[currentPlayerIndex].type != PlayerType.ai) {
      // Should not happen, but safe guard
      return;
    }

    _isProcessingTurn = true; // LOCK inputs

    // Animation
    for (int i = 0; i < 6; i++) {
      currentDiceValue = (DateTime.now().millisecondsSinceEpoch % 6) + 1;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 80));
    }

    // Actual Roll
    currentDiceValue = Random().nextInt(6) + 1;
    notifyListeners();

    // "Three Sixes" Rule
    if (currentDiceValue == 6) {
      consecutiveSixes++;
      if (consecutiveSixes >= 3) {
        await Future.delayed(const Duration(milliseconds: 500));
        consecutiveSixes = 0;
        _endTurn(); // Punish player
        return;
      }
    } else {
      consecutiveSixes = 0;
    }

    // 3. Evaluation Phase
    phase = GamePhase.moving;
    notifyListeners();

    List<Pawn> movablePawns = players[currentPlayerIndex].pawns
        .where((p) => _canMoveLogic(p))
        .toList();

    if (movablePawns.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      _endTurn();
    } else {
      final currentPlayer = players[currentPlayerIndex];

      if (currentPlayer.type == PlayerType.human) {
        // Auto-move if only 1 option
        if (movablePawns.length == 1) {
          await Future.delayed(const Duration(milliseconds: 200));
          movePawn(movablePawns.first);
        } else {
          // UNLOCK: Wait for player to click a pawn
          _isProcessingTurn = false;
        }
      } else {
        // AI Turn
        await Future.delayed(const Duration(milliseconds: 800));
        _performAiMove(movablePawns);
      }
    }
  }

  // Separated Logic from Public Check
  bool _canMoveLogic(Pawn pawn) {
    if (pawn.playerId != players[currentPlayerIndex].id) return false;
    if (pawn.stepIndex == 0 && currentDiceValue != 6) return false;
    if (pawn.stepIndex + currentDiceValue > 57) return false;
    return true;
  }

  // Public check for UI (Includes Phase checks)
  bool canMove(Pawn pawn) {
    if (phase != GamePhase.moving) return false;
    if (_isProcessingTurn) return false; // Visual helper: Grey out if busy
    return _canMoveLogic(pawn);
  }

  void movePawn(Pawn pawn) async {
    // SECURITY CHECK: This stops the spam click glitch
    if (_isProcessingTurn) return;
    if (phase != GamePhase.moving) return;
    if (!_canMoveLogic(pawn)) return;

    // IMMEDIATE LOCK
    _isProcessingTurn = true;
    notifyListeners();

    // 1. Update Model
    if (pawn.stepIndex == 0) {
      pawn.stepIndex = 1;
    } else {
      pawn.stepIndex += currentDiceValue;
    }

    // 2. Capture Logic
    _checkCaptures(pawn);

    notifyListeners();

    // 3. Animation Delay (Wait for pawn to slide)
    await Future.delayed(const Duration(milliseconds: 600));

    // 4. Decide Next Step
    if (currentDiceValue == 6) {
      phase = GamePhase.rolling;
      notifyListeners();

      if (players[currentPlayerIndex].type == PlayerType.ai) {
        // AI Chain Roll
        await Future.delayed(const Duration(milliseconds: 500));
        _isProcessingTurn = false; // Briefly unlock for internal logic
        rollDice();
      } else {
        // Human Bonus Turn
        _isProcessingTurn = false; // Unlock so human can roll again
      }
    } else {
      _endTurn();
    }
  }

  void _checkCaptures(Pawn mover) {
    // Collision logic placeholder
  }

  void _endTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    phase = GamePhase.rolling;
    consecutiveSixes = 0;
    _isProcessingTurn = false; // Reset lock
    notifyListeners();

    if (players[currentPlayerIndex].type == PlayerType.ai) {
      _isProcessingTurn = true; // Lock immediately for AI
      Future.delayed(const Duration(milliseconds: 1000), () {
        _isProcessingTurn = false; // Temp unlock to allow roll entry
        rollDice();
      });
    }
  }

  void _performAiMove(List<Pawn> options) {
    // Simple AI: Prioritize releasing 6, then furthest
    Pawn bestPawn = options.last;
    try {
      bestPawn = options.firstWhere((p) => p.stepIndex == 0);
    } catch (e) {
      bestPawn = options.last;
    }

    // We must manually unlock briefly so movePawn accepts the call
    _isProcessingTurn = false;
    movePawn(bestPawn);
  }
}
