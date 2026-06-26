import 'package:flutter/material.dart';

class GameEndDialog {
  static Future<void> show({
    required BuildContext context,
    required bool won,
    required int score,
    required VoidCallback onRestart,
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
              color: won
                  ? const Color(0xFF5B8CFF).withValues(alpha: 0.4)
                  : const Color(0xFFFF4D6D).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won
                    ? Icons.emoji_events_rounded
                    : Icons.sentiment_very_dissatisfied_rounded,
                size: 64,
                color: won
                    ? const Color(0xFF5B8CFF)
                    : const Color(0xFFFF4D6D),
              ),
              const SizedBox(height: 16),
              Text(
                won ? 'YOU WIN' : 'GAME OVER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: won ? const Color(0xFF5B8CFF) : Colors.white,
                  fontSize: 32,
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onRestart();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('REINICIAR'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
