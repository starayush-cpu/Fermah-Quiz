import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// A short, one-shot confetti burst for the quiz results screen. It
/// fires whenever a quiz ends with a score, whether the player finished
/// every question or quit early. Particles are drawn with a CustomPainter
/// and move with transform and opacity only. It plays once, lasts about
/// 2.4 seconds, never blocks taps, and renders nothing at all when the
/// user prefers reduced motion.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final math.Random rnd = math.Random();
    const List<Color> colors = <Color>[
      AppColors.teal,
      AppColors.purple,
      AppColors.sky,
      AppColors.gold,
      AppColors.navy2,
    ];
    _particles = List<_Particle>.generate(90, (_) {
      final double angle = rnd.nextDouble() * math.pi * 2;
      final double speed = 120 + rnd.nextDouble() * 260;
      return _Particle(
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed - 140,
        size: 5 + rnd.nextDouble() * 7,
        color: colors[rnd.nextInt(colors.length)],
        rotation: rnd.nextDouble() * math.pi,
        spin: (rnd.nextDouble() - 0.5) * 12,
        round: rnd.nextBool(),
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _ConfettiPainter(_particles, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.spin,
    required this.round,
  });

  final double dx;
  final double dy;
  final double size;
  final Color color;
  final double rotation;
  final double spin;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.particles, this.t);

  final List<_Particle> particles;

  /// 0 at the start of the burst, 1 when it is over.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height * 0.25;
    for (final _Particle p in particles) {
      final double x = cx + p.dx * t;
      final double y = cy + p.dy * t + 320 * t * t;
      final double opacity = t < 0.6 ? 1.0 : 1.0 - (t - 0.6) / 0.4;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.spin * t);
      final Paint paint = Paint()..color = p.color.withValues(alpha: opacity);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}
