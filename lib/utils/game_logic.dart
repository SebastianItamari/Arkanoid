import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ball.dart';
import '../models/paddle.dart';
import '../models/brick.dart';

void checkPaddleCollision({
  required Ball ball,
  required Paddle paddle,
  required double nextX,
  required double nextY,
  required bool positionsInitialized,
}) {
  if (!positionsInitialized) return;

  final ballBottom = nextY + ball.radius;
  final wasAbovePaddle = (ball.y + ball.radius) <= paddle.y;

  if (ball.vy > 0 &&
      wasAbovePaddle &&
      ballBottom >= paddle.y &&
      nextX >= paddle.x &&
      nextX <= (paddle.x + paddle.width)) {
    // Colisión: posiciona la bola justo encima de la pala y cambia velocidad
    ball.y = paddle.y - ball.radius;
    ball.vy = -ball.vy;
    final hitPos = (nextX - paddle.x) / paddle.width; // 0..1
    final delta = (hitPos - 0.5) * 2.0; // -1..1
    ball.vx += delta * 2.0;
  }
}

Offset checkBrickCollisions({
  required Ball ball,
  required List<Brick> bricks,
  required double nextX,
  required double nextY,
  required bool positionsInitialized,
  void Function(int points)? onBrickDestroyed,
}) {
  if (!positionsInitialized) return Offset(nextX, nextY);

  for (final brick in List<Brick>.from(bricks)) {
    final rect = Rect.fromLTWH(brick.x, brick.y, brick.width, brick.height);

    // Punto más cercano del rect al centro de la bola
    final nearestX = nextX.clamp(rect.left, rect.right);
    final nearestY = nextY.clamp(rect.top, rect.bottom);

    final dx = nextX - nearestX;
    final dy = nextY - nearestY;

    final distSq = dx * dx + dy * dy;
    final radiusSq = ball.radius * ball.radius;

    if (distSq <= radiusSq) {
      // Colisión detectada
      if (dx.abs() > dy.abs()) {
        // Impacto principalmente en X
        ball.vx = -ball.vx;
        if (dx > 0) {
          nextX = rect.right + ball.radius;
        } else {
          nextX = rect.left - ball.radius;
        }
      } else {
        // Impacto principalmente en Y
        ball.vy = -ball.vy;
        if (dy > 0) {
          nextY = rect.bottom + ball.radius;
        } else {
          nextY = rect.top - ball.radius;
        }
      }

      // Si es destruible, resta una vida y elimina si llega a 0
      if (!brick.indestructible) {
        brick.life -= 1;
        if (brick.life <= 0) {
          bricks.remove(brick);
          onBrickDestroyed?.call(10);
        }
      }

      // Solo procesar una colisión por tick
      break;
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

      if (p < 0.65) {
        bricks.add(Brick(
          x: x, y: y, width: bw, height: bh, life: 1, indestructible: false,
        ));
      } else if (p < 0.85) {
        bricks.add(Brick(
          x: x, y: y, width: bw, height: bh, life: 2, indestructible: false,
        ));
      } else if (p < 0.90) {
        bricks.add(Brick(
          x: x, y: y, width: bw, height: bh, life: 3, indestructible: false,
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
