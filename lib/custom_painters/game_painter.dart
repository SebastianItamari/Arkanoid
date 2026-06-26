import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GamePainter extends CustomPainter {
  final GameState gameState;

  GamePainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    final ball = gameState.ball;

    canvas.drawCircle(
      Offset(ball.x, ball.y),
      ball.radius,
      Paint()..color = Colors.white,
    );

    final paddle = gameState.paddle;

    final paddleRect = Rect.fromLTWH(
      paddle.x,
      paddle.y,
      paddle.width,
      paddle.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(paddleRect, const Radius.circular(20)),
      Paint()..color = Colors.white,
    );

    for (final brick in gameState.bricks) {
      final rect = Rect.fromLTWH(brick.x, brick.y, brick.width, brick.height);

      final brickRRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(6),
      );

      final paint = Paint();

      if (brick.indestructible) {
        paint.color = const Color(0xFF2A3555);
      } else {
        switch (brick.life) {
          case 1:
            paint.color = const Color(0xFF5B8CFF);
            break;

          case 2:
            paint.color = const Color(0xFF7C4DFF);
            break;

          case 3:
            paint.color = const Color(0xFF00D4AA);
            break;

          default:
            paint.color = const Color(0xFF5B8CFF);
        }
      }

      canvas.drawRRect(brickRRect, paint);
    }

    for (final fs in gameState.floatingScores) {
      final opacity = 1.0 - fs.progress;
      final offsetY = fs.progress * 30;

      final tp = TextPainter(
        text: TextSpan(
          text: '+10',
          style: TextStyle(
            color: Colors.white.withValues(alpha: opacity),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(fs.x - tp.width / 2, fs.y - offsetY));
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}
