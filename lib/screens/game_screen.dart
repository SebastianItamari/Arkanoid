import 'dart:async';

import 'package:flutter/material.dart';
import '../models/ball.dart';
import '../models/paddle.dart';
import '../models/brick.dart';
import '../models/game_state.dart';
import '../models/floating_score.dart';
import '../custom_painters/game_painter.dart';
import '../utils/game_logic.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_end_dialog.dart';

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
  bool _gameOver = false;
  bool _win = false;
  bool _endDialogShown = false;
  Timer? _ticker;
  double _gameWidth = 0;
  double _gameHeight = 0;
  List<FloatingScore> _floatingScores = [];

  @override
  void initState() {
    super.initState();
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
    if (_gameOver || _win) return;
    if (_ticker != null) return;
    if (_ball.vx == 0 && _ball.vy == 0) {
      _ball.vx = 3.4;
      _ball.vy = -4.6;
    }
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => update());
  }

  void _stopLoop() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _syncGameState() {
    _gameState = GameState(
      ball: _ball,
      paddle: _paddle,
      bricks: _bricks,
      score: _score,
      lives: _lives,
      floatingScores: List.from(_floatingScores),
    );
  }

  bool get _allDestroyableBricksCleared {
    return _positionsInitialized &&
        !_bricks.any((brick) => !brick.indestructible);
  }

  void _resetBallAndPaddle() {
    _paddle.x = (_gameWidth - _paddle.width) / 2;
    _ball.x = _gameWidth / 2;
    _ball.y = _paddle.y - 24;
    _ball.vx = 0;
    _ball.vy = 0;

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_gameOver || _win) return;
      if (_ball.vx == 0 && _ball.vy == 0) {
        setState(() {
          _ball.vx = 3.4;
          _ball.vy = -4.6;
          _syncGameState();
        });
      }
    });
  }

  void _finishGame({required bool won}) {
    if (_endDialogShown) return;
    _endDialogShown = true;
    _stopLoop();
    _ball.vx = 0;
    _ball.vy = 0;
    _gameOver = !won;
    _win = won;
    _syncGameState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GameEndDialog.show(
        context: context,
        won: won,
        score: _score,
        onRestart: _restartGame,
      );
    });
  }

  void _restartGame() {
    _stopLoop();
    setState(() {
      _score = 0;
      _lives = 3;
      _gameOver = false;
      _win = false;
      _endDialogShown = false;
      _positionsInitialized = false;
      _bricks = <Brick>[];
      _floatingScores = [];
      _ball.vx = 0;
      _ball.vy = 0;
      _syncGameState();
    });
  }

  void update() {
    if (!mounted) return;
    if (_gameOver || _win) return;
    double nextX = _ball.x + _ball.vx;
    double nextY = _ball.y + _ball.vy;

    final wallAdjusted = checkWallCollisions(
      ball: _ball,
      nextX: nextX,
      nextY: nextY,
      gameWidth: _gameWidth,
    );
    nextX = wallAdjusted.dx;
    nextY = wallAdjusted.dy;

    checkPaddleCollision(
      ball: _ball,
      paddle: _paddle,
      nextX: nextX,
      nextY: nextY,
      positionsInitialized: _positionsInitialized,
    );

    if (_gameHeight > 0 && nextY - _ball.radius > _gameHeight) {
      _lives = _lives > 0 ? _lives - 1 : 0;
      if (_lives == 0) {
        setState(() {
          _finishGame(won: false);
        });
        return;
      }

      _resetBallAndPaddle();
      setState(() {
        _syncGameState();
      });
      return;
    }

    final adjusted = checkBrickCollisions(
      ball: _ball,
      bricks: _bricks,
      nextX: nextX,
      nextY: nextY,
      positionsInitialized: _positionsInitialized,
      onBrickDestroyed: (points, x, y) {
        _score += points;
        _floatingScores.add(FloatingScore(x: x, y: y));
      },
    );
    nextX = adjusted.dx;
    nextY = adjusted.dy;

    for (final fs in _floatingScores) {
      fs.progress += 0.016;
    }
    _floatingScores.removeWhere((fs) => fs.progress >= 1.0);

    setState(() {
      _ball.x = nextX;
      _ball.y = nextY;
      if (_allDestroyableBricksCleared) {
        _finishGame(won: true);
      } else {
        _syncGameState();
      }
    });
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
                GameHud(
                  score: _score,
                  lives: _lives,
                  onRestart: _restartGame,
                ),
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
                              final paddleX = (w - _paddle.width) / 2;
                              final bottomPadding = MediaQuery.of(
                                context,
                              ).padding.bottom;
                              final paddleY =
                                  h -
                                  _paddle.height -
                                  bottomPadding -
                                  16;

                              final ballX = w / 2;
                              final ballY = paddleY - 24;

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                setState(() {
                                  _paddle.x = paddleX;
                                  _paddle.y = paddleY;
                                  _ball.x = ballX;
                                  _ball.y = ballY;
                                  _gameWidth = w;
                                  _gameHeight = h;

                                  final config = calculateLevelLayout(
                                    gameWidth: w,
                                    topPadding: MediaQuery.of(
                                      context,
                                    ).padding.top,
                                  );

                                  _bricks = generateLevel(
                                    rows: 1,
                                    cols: config.cols,
                                    brickWidth: config.brickWidth,
                                    brickHeight: config.brickHeight,
                                    startX: config.startX,
                                    startY: config.startY,
                                    paddingX: config.paddingX,
                                    paddingY: config.paddingY,
                                  );

                                  _gameState = GameState(
                                    ball: _ball,
                                    paddle: _paddle,
                                    bricks: _bricks,
                                    lives: _lives,
                                    score: _score,
                                    floatingScores: List.from(_floatingScores),
                                  );
                                  _positionsInitialized = true;
                                });

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
                                    floatingScores: List.from(_floatingScores),
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
