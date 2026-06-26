import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ball.dart';
import '../models/paddle.dart';
import '../models/brick.dart';
import '../models/level_config.dart';

void checkPaddleCollision({
  required Ball ball,
  required Paddle paddle,
  required double nextX,
  required double nextY,
  required bool positionsInitialized,
  double targetSpeed = 5.8,
}) {
  if (!positionsInitialized) return;

  final ballBottom = nextY + ball.radius;
  final wasAbovePaddle = (ball.y + ball.radius) <= paddle.y;

  if (ball.vy > 0 &&
      wasAbovePaddle &&
      ballBottom >= paddle.y &&
      nextX >= paddle.x &&
      nextX <= (paddle.x + paddle.width)) {
    ball.y = paddle.y - ball.radius;
    ball.vy = -ball.vy;
    final hitPos = (nextX - paddle.x) / paddle.width;
    final delta = (hitPos - 0.5) * 2.0;
    ball.vx += delta * 2.0;
    final speed = sqrt(ball.vx * ball.vx + ball.vy * ball.vy);
    ball.vx = ball.vx / speed * targetSpeed;
    ball.vy = ball.vy / speed * targetSpeed;
  }
}

Offset checkWallCollisions({
  required Ball ball,
  required double nextX,
  required double nextY,
  required double gameWidth,
}) {
  if (nextX - ball.radius <= 0) {
    nextX = ball.radius;
    ball.vx = -ball.vx;
  } else if (nextX + ball.radius >= gameWidth && gameWidth > 0) {
    nextX = gameWidth - ball.radius;
    ball.vx = -ball.vx;
  }

  if (nextY - ball.radius <= 0) {
    nextY = ball.radius;
    ball.vy = -ball.vy;
  }

  return Offset(nextX, nextY);
}

Offset checkBrickCollisions({
  required Ball ball,
  required List<Brick> bricks,
  required double nextX,
  required double nextY,
  required bool positionsInitialized,
  void Function(int points, double x, double y)? onBrickDestroyed,
}) {
  if (!positionsInitialized) return Offset(nextX, nextY);

  for (final brick in List<Brick>.from(bricks)) {
    final rect = Rect.fromLTWH(brick.x, brick.y, brick.width, brick.height);

    final nearestX = nextX.clamp(rect.left, rect.right);
    final nearestY = nextY.clamp(rect.top, rect.bottom);

    final dx = nextX - nearestX;
    final dy = nextY - nearestY;

    final distSq = dx * dx + dy * dy;
    final radiusSq = ball.radius * ball.radius;

    if (distSq <= radiusSq) {
      final useX = dx.abs() > dy.abs() ||
          (dx == 0 && dy == 0 && ball.vx.abs() > ball.vy.abs());
      if (useX) {
        ball.vx = -ball.vx;
        if (dx > 0) {
          nextX = rect.right + ball.radius;
        } else if (dx < 0) {
          nextX = rect.left - ball.radius;
        } else {
          nextX = ball.vx > 0 ? rect.right + ball.radius : rect.left - ball.radius;
        }
      } else {
        ball.vy = -ball.vy;
        if (dy > 0) {
          nextY = rect.bottom + ball.radius;
        } else if (dy < 0) {
          nextY = rect.top - ball.radius;
        } else {
          nextY = ball.vy > 0 ? rect.bottom + ball.radius : rect.top - ball.radius;
        }
      }

      if (!brick.indestructible) {
        brick.life -= 1;
        if (brick.life <= 0) {
          final centerX = brick.x + brick.width / 2;
          final centerY = brick.y + brick.height / 2;
          bricks.remove(brick);
          onBrickDestroyed?.call(10, centerX, centerY);
        }
      }
    }
  }

  return Offset(nextX, nextY);
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
  double hitChance = 0.2,
  double indestructibleChance = 0.0,
}) {
  final List<Brick> bricks = [];
  final rnd = Random();

  final bw = brickWidth.isFinite ? brickWidth.clamp(8.0, double.infinity) : 8.0;
  final bh = brickHeight.isFinite
      ? brickHeight.clamp(8.0, double.infinity)
      : 8.0;

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      final x = startX + c * (bw + paddingX);
      final y = startY + r * (bh + paddingY);

      final double p = rnd.nextDouble();
      final double oneHitThreshold = 1.0 - hitChance - indestructibleChance;

      if (p < oneHitThreshold) {
        bricks.add(Brick(
          x: x, y: y, width: bw, height: bh, life: 1, indestructible: false,
        ));
      } else if (p < 1.0 - indestructibleChance) {
        final int life = rnd.nextDouble() < 0.67 ? 2 : 3;
        bricks.add(Brick(
          x: x, y: y, width: bw, height: bh, life: life, indestructible: false,
        ));
      } else {
        bricks.add(Brick(
          x: x, y: y, width: bw, height: bh, life: 0, indestructible: true,
        ));
      }
    }
  }

  return bricks;
}

LevelConfig calculateLevelLayout({
  required double gameWidth,
  required double topPadding,
  double startX = 12.0,
  double paddingX = 6.0,
  double paddingY = 6.0,
  double targetBrickWidth = 44.0,
  int rows = 1,
  double brickHeight = 18.0,
}) {
  int cols = ((gameWidth + paddingX) / (targetBrickWidth + paddingX)).floor();
  if (cols < 1) cols = 1;
  final availableForBricks = gameWidth - (startX * 2) - (paddingX * (cols - 1));
  double brickWidth = availableForBricks / cols;
  if (!brickWidth.isFinite || brickWidth <= 8.0) {
    brickWidth = targetBrickWidth.clamp(8.0, gameWidth - (startX * 2));
  }
  final startY = topPadding + 24.0;

  return LevelConfig(
    cols: cols,
    brickWidth: brickWidth,
    brickHeight: brickHeight,
    startX: startX,
    startY: startY,
    paddingX: paddingX,
    paddingY: paddingY,
  );
}
