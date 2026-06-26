import 'package:flutter/material.dart';

class LevelCompleteDialog {
  static Future<void> show({
    required BuildContext context,
    required int level,
    required int score,
    required int lives,
    required VoidCallback onNextLevel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131B33),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: const Color(0xFF5B8CFF).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: Color(0xFF5B8CFF),
              ),
              const SizedBox(height: 16),
              Text(
                'LEVEL $level COMPLETE!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5B8CFF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SCORE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                score.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D6D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF4D6D).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFFF4D6D)),
                    const SizedBox(width: 6),
                    Text(
                      '+1 VIDA ($lives)',
                      style: const TextStyle(
                        color: Color(0xFFFF4D6D),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onNextLevel();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('SIGUIENTE NIVEL'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
