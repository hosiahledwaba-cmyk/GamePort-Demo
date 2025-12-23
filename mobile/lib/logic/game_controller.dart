import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/player.dart';
import '../models/pawn.dart';
import '../utils/path_map.dart';

enum GamePhase { rolling, moving, anim, win }

class GameController extends ChangeNotifier {
  final List<Player> players = [];
  int currentPlayerIndex = 0;
  int currentDiceValue = 1;
  int consecutiveSixes = 0;
  GamePhase phase = GamePhase.rolling;

  bool _locked = false;
  Player? winner;

  /* -------------------- GAME SETUP -------------------- */

  void startGame(int playerCount) {
    players.clear();
    const colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];

    players.add(Player(id: 0, color: colors[0], type: PlayerType.human));
    for (int i = 1; i < playerCount; i++) {
      players.add(Player(id: i, color: colors[i], type: PlayerType.ai));
    }

    currentPlayerIndex = 0;
    currentDiceValue = 1;
    consecutiveSixes = 0;
    phase = GamePhase.rolling;
    winner = null;
    _locked = false;

    notifyListeners();
  }

  /* -------------------- DICE ROLL -------------------- */

  Future<void> rollDice() async {
    if (phase != GamePhase.rolling || _locked) return;
    _lock();

    // Dice animation
    for (int i = 0; i < 6; i++) {
      currentDiceValue = Random().nextInt(6) + 1;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 80));
    }

    currentDiceValue = Random().nextInt(6) + 1;
    notifyListeners();

    // Three sixes rule
    if (currentDiceValue == 6) {
      consecutiveSixes++;
      if (consecutiveSixes >= 3) {
        consecutiveSixes = 0;
        await Future.delayed(const Duration(milliseconds: 400));
        _unlock();
        _endTurn();
        return;
      }
    } else {
      consecutiveSixes = 0;
    }

    phase = GamePhase.moving;
    notifyListeners();

    final movable = _movablePawns();

    if (movable.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      _unlock();
      _endTurn();
      return;
    }

    final player = players[currentPlayerIndex];

    // Unlock strictly for the move selection phase
    _unlock();

    if (player.type == PlayerType.ai) {
      await Future.delayed(const Duration(milliseconds: 600));
      _performAiMove(movable);
    }
  }

  /* -------------------- MOVEMENT -------------------- */

  bool canMove(Pawn pawn) =>
      phase == GamePhase.moving && !_locked && _canMoveLogic(pawn);

  bool _canMoveLogic(Pawn pawn) {
    if (pawn.playerId != players[currentPlayerIndex].id) return false;
    // Rule: Must roll 6 to enter board
    if (pawn.stepIndex == 0) return currentDiceValue == 6;
    // Rule: Exact throw to reach home
    if (pawn.stepIndex + currentDiceValue > 57) return false;
    return true;
  }

  Future<void> movePawn(Pawn pawn) async {
    if (!canMove(pawn)) return;
    _lock();

    // 1. Base Exit (Slide animation)
    if (pawn.stepIndex == 0) {
      pawn.stepIndex = 1;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
    }
    // 2. Path Movement (Hopping animation)
    else {
      int steps = currentDiceValue;
      while (steps-- > 0) {
        pawn.stepIndex++;
        notifyListeners();
        // Wait for hop (matches UI duration)
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    // Handle collisions
    bool captured = _handleCollisions(pawn);
    if (captured) {
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    // Home reached check
    if (pawn.stepIndex == 57) {
      players[currentPlayerIndex].completedPawns++;
      if (players[currentPlayerIndex].completedPawns == 4) {
        winner = players[currentPlayerIndex];
        phase = GamePhase.win;
        _unlock();
        notifyListeners();
        return;
      }
    }

    // Extra turn conditions (6, Capture, or Home)
    if (currentDiceValue == 6 || captured || pawn.stepIndex == 57) {
      phase = GamePhase.rolling;
      notifyListeners();
      _unlock();

      if (players[currentPlayerIndex].type == PlayerType.ai) {
        await Future.delayed(const Duration(milliseconds: 500));
        rollDice();
      }
      return;
    }

    _unlock();
    _endTurn();
  }

  /* -------------------- COLLISIONS -------------------- */

  /// Checks for collisions on the physical tile the pawn landed on.
  /// Modifies game state (sends opponent home) if capture occurs.
  bool _handleCollisions(Pawn mover) {
    final moverPos = PathMap.getPixelCoordinates(mover, mover.playerId, 1.0);

    // FIXED: Use PathMap to check physical tile safety.
    // If the tile is safe, NO CUTTING happens regardless of pawn state.
    if (PathMap.isSafeSpot(moverPos)) return false;

    bool cut = false;

    for (final player in players) {
      if (player.id == mover.playerId) continue;

      for (final pawn in player.pawns) {
        // Ignore pawns in Base or Home or Safe Zone > 51
        if (pawn.stepIndex == 0 || pawn.stepIndex > 51) continue;

        final otherPos = PathMap.getPixelCoordinates(pawn, player.id, 1.0);

        // Simple distance check for "Same Tile"
        if ((moverPos - otherPos).distance < 0.01) {
          pawn.stepIndex = 0; // Send back to base
          cut = true;
        }
      }
    }
    return cut;
  }

  /* -------------------- TURN FLOW -------------------- */

  void _endTurn() {
    consecutiveSixes = 0;
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    phase = GamePhase.rolling;
    notifyListeners();

    if (players[currentPlayerIndex].type == PlayerType.ai) {
      Future.delayed(const Duration(milliseconds: 800), rollDice);
    }
  }

  List<Pawn> _movablePawns() =>
      players[currentPlayerIndex].pawns.where(_canMoveLogic).toList();

  /* -------------------- AI -------------------- */

  void _performAiMove(List<Pawn> options) {
    Pawn best = options.first;

    // Priority 1: Capture Opponent
    for (final pawn in options) {
      if (_wouldCapture(pawn)) {
        best = pawn;
        movePawn(best);
        return;
      }
    }

    // Priority 2: Enter from base (if rolled 6)
    try {
      best = options.firstWhere((p) => p.stepIndex == 0);
    } catch (e) {
      // Priority 3: Move pawn closest to home
      best = options.reduce((a, b) => a.stepIndex > b.stepIndex ? a : b);
    }

    movePawn(best);
  }

  /// Simulates a move to check if it lands on an opponent
  /// DOES NOT modify actual game state.
  bool _wouldCapture(Pawn pawn) {
    // 1. Calculate Target Index
    int target = pawn.stepIndex == 0 ? 1 : pawn.stepIndex + currentDiceValue;

    // Safety check
    if (target > 57) return false;

    // 2. Create a Dummy Pawn to check coordinates
    final testPawn = Pawn(
      id: pawn.id,
      playerId: pawn.playerId,
      color: pawn.color,
      stepIndex: target,
    );

    // 3. Calculate simulated position
    final testPos = PathMap.getPixelCoordinates(testPawn, pawn.playerId, 1.0);

    // 4. Check if this position is a Safe Spot
    if (PathMap.isSafeSpot(testPos)) return false;

    // 5. Check against all opponents
    for (final player in players) {
      if (player.id == pawn.playerId) continue;

      for (final other in player.pawns) {
        if (other.stepIndex == 0 || other.stepIndex > 51) continue;

        final otherPos = PathMap.getPixelCoordinates(other, player.id, 1.0);

        if ((testPos - otherPos).distance < 0.01) {
          return true; // Capture detected
        }
      }
    }
    return false;
  }

  /* -------------------- LOCKING -------------------- */

  void _lock() => _locked = true;
  void _unlock() => _locked = false;
}
