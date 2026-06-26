import 'package:flutter/material.dart';
import '../models/ball.dart';
import '../models/paddle.dart';
import '../models/game_state.dart';
import '../utils/game_logic.dart';
import '../custom_painters/game_painter.dart';

class GamePreviewWidget extends StatelessWidget {
  const GamePreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;

        if (w <= 0 || h <= 0) return const SizedBox.shrink();

        final paddle = Paddle(
          x: (w - 70) / 2,
          y: h - 18,
          width: 70,
          height: 10,
        );

        final ball = Ball(
          x: w / 2,
          y: paddle.y - 20,
          radius: 6,
          vx: 0,
          vy: 0,
        );

        const double gap = 6;
        final double startX = 8;
        int cols = ((w - startX * 2 + gap) / (38 + gap)).floor();
        if (cols < 3) cols = 3;
        double brickWidth = (w - startX * 2 - gap * (cols - 1)) / cols;

        final bricks = generateLevel(
          rows: 4,
          cols: cols,
          brickWidth: brickWidth,
          brickHeight: 14,
          startX: startX,
          startY: 12,
          paddingX: gap,
          paddingY: gap,
        );

        return CustomPaint(
          painter: GamePainter(GameState(
            ball: ball,
            paddle: paddle,
            bricks: bricks,
          )),
          size: Size(w, h),
        );
      },
    );
  }
}
