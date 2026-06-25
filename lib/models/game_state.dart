import 'ball.dart';
import 'brick.dart';
import 'paddle.dart';
import 'dart:math';

class GameState {
  Ball ball;
  Paddle paddle;
  List<Brick> bricks;
  int score;
  int lives;
  GameState({
    required this.ball,
    required this.paddle,
    required this.bricks,
    this.score = 0,
    this.lives = 3,
  });
}

List<Brick> generateLevel({
  required int rows,
  required int cols,
  required double brickWidth,
  required double brickHeight,
  double startX = 0,
  double startY = 0,
  double paddingX = 4,
  double paddingY = 4,
}) {
  final List<Brick> bricks = [];
  final rnd = Random();

  // Control added for wrong values
  final bw = brickWidth.isFinite ? brickWidth.clamp(8.0, double.infinity) : 8.0;
  final bh = brickHeight.isFinite
      ? brickHeight.clamp(8.0, double.infinity)
      : 8.0;

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      final x = startX + c * (bw + paddingX);
      final y = startY + r * (bh + paddingY);

      final double p = rnd.nextDouble();

      if (p < 0.65) {
        // Normal (life = 1)
        bricks.add(
          Brick(
            x: x,
            y: y,
            width: bw,
            height: bh,
            life: 1,
            indestructible: false,
          ),
        );
      } else if (p < 0.85) {
        // Tough (life = 2)
        bricks.add(
          Brick(
            x: x,
            y: y,
            width: bw,
            height: bh,
            life: 2,
            indestructible: false,
          ),
        );
      } else if (p < 0.90) {
        // Very tough (life = 3)
        bricks.add(
          Brick(
            x: x,
            y: y,
            width: bw,
            height: bh,
            life: 3,
            indestructible: false,
          ),
        );
      } else {
        // Indestructible
        bricks.add(
          Brick(
            x: x,
            y: y,
            width: bw,
            height: bh,
            life: 0,
            indestructible: true,
          ),
        );
      }
    }
  }

  return bricks;
}
