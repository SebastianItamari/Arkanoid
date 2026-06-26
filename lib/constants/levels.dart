import '../models/level_data.dart';

// Each entry: (rows, paddleWidth, targetSpeed, hitChance, indestructibleChance)
//   rows: number of brick rows
//   paddleWidth: paddle width in pixels (narrower = harder)
//   targetSpeed: ball speed after paddle hit (higher = harder)
//   hitChance: probability of 2-3 hit bricks
//   indestructibleChance: probability of unbreakable bricks

const levels = [
  LevelData(1, 100.0, 5.8, 0.05, 0.00),
  LevelData(2, 90.0, 6.5, 0.25, 0.05),
  LevelData(3, 80.0, 7.2, 0.45, 0.10),
  LevelData(5, 70.0, 8.2, 0.65, 0.20),
];
