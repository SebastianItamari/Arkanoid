import 'ball.dart';
import 'brick.dart';
import 'paddle.dart';
import 'floating_score.dart';

class GameState {
  Ball ball;
  Paddle paddle;
  List<Brick> bricks;
  int score;
  int lives;
  List<FloatingScore> floatingScores;
  GameState({
    required this.ball,
    required this.paddle,
    required this.bricks,
    this.score = 0,
    this.lives = 3,
    this.floatingScores = const [],
  });
}
