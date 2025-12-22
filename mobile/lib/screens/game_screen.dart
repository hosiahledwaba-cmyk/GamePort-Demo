import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/glass_design.dart';
import '../logic/game_controller.dart';
import '../widgets/ludo_board.dart';
import '../widgets/dice_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: GlassContainer(
                  height: 60,
                  borderRadius: BorderRadius.circular(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Ludo Glass",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // The Board (Centered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LudoBoard(),
              ),

              const Spacer(),

              // Controls
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GlassContainer(
                  height: 140,
                  borderRadius: BorderRadius.circular(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Player Info
                      Consumer<GameController>(
                        builder: (context, game, _) {
                          final player = game.players[game.currentPlayerIndex];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "PLAYER ${player.id + 1}",
                                style: TextStyle(
                                  color: player.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                game.phase == GamePhase.rolling
                                    ? "Roll Dice"
                                    : "Move Pawn",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Divider
                      Container(width: 1, height: 60, color: Colors.white24),

                      // Dice
                      const DiceWidget(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
