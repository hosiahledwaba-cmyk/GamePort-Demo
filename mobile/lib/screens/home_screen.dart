import 'package:flutter/material.dart';
import 'package:gameport/screens/game_screen.dart';
import 'package:provider/provider.dart';
import '../theme/glass_design.dart';
import '../logic/game_controller.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title with Glass Effect
              GlassContainer(
                width: 300,
                height: 120,
                blur: 20,
                child: Center(
                  child: Text(
                    "LUDO GLASS",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Action Buttons
              _buildMenuButton(context, "Vs AI (2 Players)", 2),
              const SizedBox(height: 20),
              _buildMenuButton(context, "Vs AI (4 Players)", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, int players) {
    return GlassContainer(
      width: 250,
      height: 70,
      borderRadius: BorderRadius.circular(35),
      onTap: () {
        context.read<GameController>().startGame(players);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}
