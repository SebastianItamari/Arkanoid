import 'ball.dart';
import 'brick.dart';
import 'paddle.dart';

class GameState {
  Ball ball;
  Paddle paddle;
  List<Brick> bricks;
  GameState({required this.ball, required this.paddle, required this.bricks});
}
