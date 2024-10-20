import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  int gridSizeX = 10;
  int gridSizeY = 10;
  List<Offset> snake = [const Offset(5.0, 5.0)];
  Offset food = const Offset(0.0, 0.0);
  Direction direction = Direction.right;
  bool isGameOver = true;
  Timer? gameLoop;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _initKeyboard();
    gameLoop = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (isGameOver) {
        timer.cancel();
        return;
      }
      moveSnake();
    });
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    _removeKeyboardListener();
    super.dispose();
  }

  void moveSnake() {
    Offset head = snake.first;
    Offset newHead;
    switch (direction) {
      case Direction.up:
        newHead = Offset(head.dx, head.dy - 1.0);
        break;
      case Direction.down:
        newHead = Offset(head.dx, head.dy + 1.0);
        break;
      case Direction.left:
        newHead = Offset(head.dx - 1.0, head.dy);
        break;
      case Direction.right:
        newHead = Offset(head.dx + 1.0, head.dy);
        break;
    }

    if (newHead.dx < 0 ||
        newHead.dx >= gridSizeX ||
        newHead.dy < 0 ||
        newHead.dy >= gridSizeY ||
        snake.contains(newHead)) {
      setState(() {
        isGameOver = true;
      });
      return;
    }

    setState(() {
      snake.insert(0, newHead);
      if (newHead == food) {
        score++;
        Offset newFood;
        do {
          newFood = Offset(Random().nextInt(gridSizeX).toDouble(),
              Random().nextInt(gridSizeY).toDouble());
        } while (snake.contains(newFood));
        food = newFood;
      } else {
        snake.removeLast();
      }
    });
  }

  void changeDirection(Direction newDirection) {
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    setState(() {
      direction = newDirection;
    });
  }

  void _initKeyboard() {
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _removeKeyboardListener() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
  }

  final Map<LogicalKeyboardKey, Direction> _keyMap = {
    LogicalKeyboardKey.arrowUp: Direction.up,
    LogicalKeyboardKey.arrowDown: Direction.down,
    LogicalKeyboardKey.arrowLeft: Direction.left,
    LogicalKeyboardKey.arrowRight: Direction.right,
    LogicalKeyboardKey.keyW: Direction.up,
    LogicalKeyboardKey.keyS: Direction.down,
    LogicalKeyboardKey.keyA: Direction.left,
    LogicalKeyboardKey.keyD: Direction.right,
    LogicalKeyboardKey.numpad8: Direction.up,
    LogicalKeyboardKey.numpad2: Direction.down,
    LogicalKeyboardKey.numpad4: Direction.left,
    LogicalKeyboardKey.numpad6: Direction.right,
  };

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent && _keyMap.containsKey(event.logicalKey)) {
      changeDirection(_keyMap[event.logicalKey]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Score: $score',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy > 0) {
              changeDirection(Direction.down);
            } else {
              changeDirection(Direction.up);
            }
          },
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 0) {
              changeDirection(Direction.right);
            } else {
              changeDirection(Direction.left);
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minDimension =
                  min(constraints.maxWidth, constraints.maxHeight);
              gridSizeX = (constraints.maxWidth / minDimension * 10).round();
              gridSizeY = (constraints.maxHeight / minDimension * 10).round();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isGameOver)
                    Expanded(
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: SnakePainter(
                            snake, food, constraints, gridSizeX, gridSizeY),
                      ),
                    ),
                  if (isGameOver)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                snake = [const Offset(5.0, 5.0)];
                                food = Offset(
                                    Random().nextInt(gridSizeX).toDouble(),
                                    Random().nextInt(gridSizeY).toDouble());
                                direction = Direction.right;
                                isGameOver = false;
                                score = 0;
                                gameLoop = Timer.periodic(
                                    const Duration(milliseconds: 200), (timer) {
                                  if (isGameOver) {
                                    timer.cancel();
                                    return;
                                  }
                                  moveSnake();
                                });
                              });
                            },
                            child: const Text('Play'),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Swipe to change direction',
                            style: TextStyle(
                                color: Colors.white), // Changed text color
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final BoxConstraints constraints;
  final int gridSizeX;
  final int gridSizeY;

  SnakePainter(
      this.snake, this.food, this.constraints, this.gridSizeX, this.gridSizeY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;
    final foodPaint = Paint()..color = Colors.red;
    final cellSizeX = constraints.maxWidth / gridSizeX;
    final cellSizeY = constraints.maxHeight / gridSizeY;

    for (var offset in snake) {
      canvas.drawRect(
          Rect.fromLTWH(offset.dx * cellSizeX, offset.dy * cellSizeY, cellSizeX,
              cellSizeY),
          paint);
    }
    canvas.drawRect(
        Rect.fromLTWH(
            food.dx * cellSizeX, food.dy * cellSizeY, cellSizeX, cellSizeY),
        foodPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
