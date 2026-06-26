import '../models/level_data.dart';

// Each entry: (rows, paddleWidth, targetSpeed, hitChance, indestructibleChance)
//   rows: number of brick rows
//   paddleWidth: paddle width in pixels (narrower = harder)
//   targetSpeed: ball speed after paddle hit (higher = harder)
//   hitChance: probability of 2-3 hit bricks
//   indestructibleChance: probability of unbreakable bricks

const levels = [
  LevelData(1, 100.0, 5.8, 0.05, 0.00),
  LevelData(2, 96.0, 6.3, 0.25, 0.05),
  LevelData(3, 90.0, 7.0, 0.40, 0.10),
  LevelData(5, 80.0, 8.0, 0.60, 0.20),
];
