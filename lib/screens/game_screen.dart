import 'package:flutter/material.dart';
import '../models/ball.dart';
import '../models/paddle.dart';
import '../models/brick.dart';
import '../models/game_state.dart';
import '../game_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Ball _ball;
  late Paddle _paddle;
  late List<Brick> _bricks;
  late GameState _gameState;
  bool _positionsInitialized = false;

  @override
  void initState() {
    super.initState();

    // Default sizes - positions will be adjusted once we know canvas size.
    _ball = Ball(x: 100, y: 100, radius: 8, vx: 0, vy: 0);
    _paddle = Paddle(x: 0, y: 0, width: 100, height: 12);
    _bricks = <Brick>[];
    _gameState = GameState(ball: _ball, paddle: _paddle, bricks: _bricks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF131B33), Color(0xFF0B1020)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF131B33), Color(0xFF0B1020)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x225B8CFF),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    if (!_positionsInitialized && w > 0 && h > 0) {
                      // Place paddle centered horizontally and near bottom inside the game area.
                      final paddleX = (w - _paddle.width) / 2;
                      // Respecta el SafeArea inferior usando MediaQuery.padding.bottom.
                      final bottomPadding = MediaQuery.of(
                        context,
                      ).padding.bottom;
                      final paddleY =
                          h -
                          _paddle.height -
                          bottomPadding -
                          16; // 8 px extra margin

                      // Place ball above paddle by default
                      final ballX = w / 2;
                      final ballY = paddleY - 24; // 24 px above paddle

                      // Evita llamar a setState durante build: programa la actualización
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() {
                          _paddle.x = paddleX;
                          _paddle.y = paddleY;
                          _ball.x = ballX;
                          _ball.y = ballY;
                          _gameState = GameState(
                            ball: _ball,
                            paddle: _paddle,
                            bricks: _bricks,
                          );
                          _positionsInitialized = true;
                        });
                      });
                    }

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        final dx = details.delta.dx;
                        double maxX = w - _paddle.width;
                        if (maxX < 0) maxX = 0;
                        double newX = _paddle.x + dx;
                        if (newX < 0) newX = 0;
                        if (newX > maxX) newX = maxX;
                        setState(() {
                          _paddle.x = newX;
                          _gameState = GameState(
                            ball: _ball,
                            paddle: _paddle,
                            bricks: _bricks,
                          );
                        });
                      },
                      child: CustomPaint(
                        painter: GamePainter(_gameState),
                        child: const SizedBox.expand(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
