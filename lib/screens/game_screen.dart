import 'dart:async';

import 'package:flutter/material.dart';
import '../models/ball.dart';
import '../models/paddle.dart';
import '../models/brick.dart';
import '../models/game_state.dart';
import '../game_painter.dart';
import '../game_logic.dart';

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
  int _score = 0;
  int _lives = 3;
  bool _positionsInitialized = false;
  Timer? _ticker;
  double _gameWidth = 0;
  double _gameHeight = 0;

  @override
  void initState() {
    super.initState();

    // Default sizes - positions will be adjusted once we know canvas size.
    _ball = Ball(x: 100, y: 100, radius: 8, vx: 0, vy: 0);
    _paddle = Paddle(x: 0, y: 0, width: 100, height: 12);
    _bricks = <Brick>[];
    _gameState = GameState(
      ball: _ball,
      paddle: _paddle,
      bricks: _bricks,
      score: _score,
      lives: _lives,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startLoopIfNeeded() {
    if (_ticker != null) return;
    // Establece una velocidad inicial razonable si está en reposo.
    if (_ball.vx == 0 && _ball.vy == 0) {
      _ball.vx = 3.4; // pixels per tick (~150 px/s at 60fps)
      _ball.vy = -4.6;
    }
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => update());
  }

  void _resetBallAndPaddle() {
    _paddle.x = (_gameWidth - _paddle.width) / 2;
    _ball.x = _gameWidth / 2;
    _ball.y = _paddle.y - 24;
    _ball.vx = 0;
    _ball.vy = 0;

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_ball.vx == 0 && _ball.vy == 0) {
        setState(() {
          _ball.vx = 3.4;
          _ball.vy = -4.6;
          _gameState = GameState(
            ball: _ball,
            paddle: _paddle,
            bricks: _bricks,
            score: _score,
            lives: _lives,
          );
        });
      }
    });
  }

  void update() {
    if (!mounted) return;
    // Mueve la pelota
    double nextX = _ball.x + _ball.vx;
    double nextY = _ball.y + _ball.vy;

    // Rebote en paredes laterales
    if (nextX - _ball.radius <= 0) {
      nextX = _ball.radius;
      _ball.vx = -_ball.vx;
    } else if (nextX + _ball.radius >= _gameWidth && _gameWidth > 0) {
      nextX = _gameWidth - _ball.radius;
      _ball.vx = -_ball.vx;
    }

    // Rebote en techo
    if (nextY - _ball.radius <= 0) {
      nextY = _ball.radius;
      _ball.vy = -_ball.vy;
    }

    // Collision con la pala
    checkPaddleCollision(
      ball: _ball,
      paddle: _paddle,
      nextX: nextX,
      nextY: nextY,
      positionsInitialized: _positionsInitialized,
    );

    if (_gameHeight > 0 && nextY - _ball.radius > _gameHeight) {
      _lives = _lives > 0 ? _lives - 1 : 0;
      _resetBallAndPaddle();
      setState(() {
        _gameState = GameState(
          ball: _ball,
          paddle: _paddle,
          bricks: _bricks,
          score: _score,
          lives: _lives,
        );
      });
      return;
    }

    final adjusted = checkBrickCollisions(
      ball: _ball,
      bricks: _bricks,
      nextX: nextX,
      nextY: nextY,
      positionsInitialized: _positionsInitialized,
      onBrickDestroyed: (points) {
        setState(() {
          _score += points;
          _gameState = GameState(
            ball: _ball,
            paddle: _paddle,
            bricks: _bricks,
            score: _score,
            lives: _lives,
          );
        });
      },
    );
    nextX = adjusted.dx;
    nextY = adjusted.dy;

    setState(() {
      _ball.x = nextX;
      _ball.y = nextY;
      _gameState = GameState(
        ball: _ball,
        paddle: _paddle,
        bricks: _bricks,
        score: _score,
        lives: _lives,
      );
    });
  }

  Widget _buildHud() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xCC0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHudItem('Score', _score.toString()),
          _buildHudItem('Lives', _lives.toString()),
        ],
      ),
    );
  }

  Widget _buildHudItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                _buildHud(),
                const SizedBox(height: 14),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: Container(
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
                                  _gameWidth = w;
                                  _gameHeight = h;

                                  const double startX = 12.0;
                                  const double paddingX = 6.0;
                                  const double paddingY = 6.0;
                                  const double targetBrickWidth = 44.0;
                                  int cols =
                                      ((w + paddingX) /
                                              (targetBrickWidth + paddingX))
                                          .floor();
                                  if (cols < 1) cols = 1;
                                  final availableForBricks =
                                      w -
                                      (startX * 2) -
                                      (paddingX * (cols - 1));
                                  double brickWidth = availableForBricks / cols;
                                  if (!brickWidth.isFinite ||
                                      brickWidth <= 8.0) {
                                    brickWidth = targetBrickWidth.clamp(
                                      8.0,
                                      w - (startX * 2),
                                    );
                                  }
                                  const int rows = 8;
                                  final brickHeight = 18.0;
                                  final topPadding = MediaQuery.of(
                                    context,
                                  ).padding.top;
                                  final startYAdjusted = topPadding + 24.0;

                                  _bricks = generateLevel(
                                    rows: rows,
                                    cols: cols,
                                    brickWidth: brickWidth,
                                    brickHeight: brickHeight,
                                    startX: startX,
                                    startY: startYAdjusted,
                                    paddingX: paddingX,
                                    paddingY: paddingY,
                                  );

                                  _gameState = GameState(
                                    ball: _ball,
                                    paddle: _paddle,
                                    bricks: _bricks,
                                    lives: _lives,
                                    score: _score,
                                  );
                                  _positionsInitialized = true;
                                });

                                // Inicia el loop de actualización si aún no está corriendo.
                                _startLoopIfNeeded();
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
                                    score: _score,
                                    lives: _lives,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
