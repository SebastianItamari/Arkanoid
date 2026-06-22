import 'ball.dart';
import 'brick.dart';
import 'paddle.dart';

class GameState {
  Ball ball;
  Paddle paddle;
  List<Brick> bricks;

  GameState({required this.ball, required this.paddle, required this.bricks});

  /// Crea un estado por defecto con valores placeholder.
  factory GameState.defaultState() {
    return GameState(
      ball: Ball(100, 100, 8, 0, 0),
      paddle: Paddle(120, 400, 120, 16),
      bricks: [],
    );
  }
}
