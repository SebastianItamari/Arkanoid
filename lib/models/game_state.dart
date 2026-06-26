import 'ball.dart';
import 'brick.dart';
import 'paddle.dart';

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
