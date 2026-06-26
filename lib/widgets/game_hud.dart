import 'package:flutter/material.dart';
import 'game_hud_item.dart';

class GameHud extends StatelessWidget {
  final int score;
  final int lives;
  final VoidCallback onRestart;

  const GameHud({
    super.key,
    required this.score,
    required this.lives,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xDD0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GameHudItem(
            icon: Icons.stars_rounded,
            iconColor: const Color(0xFF5B8CFF),
            label: 'Score',
            value: score.toString(),
          ),
          GameHudItem(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFFF4D6D),
            label: 'Lives',
            value: lives.toString(),
          ),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text(
              'REINICIAR',
              style: TextStyle(fontSize: 12, letterSpacing: 1),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5B8CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
