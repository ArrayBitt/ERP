import 'dart:math';
import 'package:flutter/material.dart';

class SnowBackground extends StatefulWidget {
  const SnowBackground({Key? key}) : super(key: key);

  @override
  State<SnowBackground> createState() => _SnowBackgroundState();
}

class _SnowBackgroundState extends State<SnowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<_Snowflake> _flakes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < 120; i++) {
      _flakes.add(_Snowflake(_random));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _SnowPainter(_flakes),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Snowflake {
  late double x;
  late double y;
  late double radius;
  late double speed;

  _Snowflake(Random random) {
    x = random.nextDouble() * 400;
    y = random.nextDouble() * 800;
    radius = random.nextDouble() * 2 + 1;
    speed = random.nextDouble() * 1.5 + 0.5;
  }
}

class _SnowPainter extends CustomPainter {
  final List<_Snowflake> flakes;
  _SnowPainter(this.flakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);

    for (var f in flakes) {
      f.y += f.speed;
      if (f.y > size.height) f.y = 0;
      canvas.drawCircle(Offset(f.x % size.width, f.y), f.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
