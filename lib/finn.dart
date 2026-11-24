import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Finn the dolphin mascot, drawn with shapes.
/// Same look as the SVG mascot in the HTML version: blue dolphin, purple
/// cap with an F, friendly face.
class FinnPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 220.0;
    final double sy = size.height / 170.0;
    final double s = math.min(sx, sy);
    canvas.save();
    canvas.translate(
      (size.width - 220.0 * s) / 2.0,
      (size.height - 170.0 * s) / 2.0,
    );
    canvas.scale(s);

    final Paint darkBlue = Paint()..color = const Color(0xFF2E7FA8);
    final Paint bodyBlue = Paint()..color = const Color(0xFF4AA8D8);
    final Paint belly = Paint()..color = const Color(0xFFBFE6F5);
    final Paint navy = Paint()..color = const Color(0xFF051624);
    final Paint white = Paint()..color = Colors.white;
    final Paint purple = Paint()..color = const Color(0xFF9553BE);

    // Tail.
    final Path tail = Path()
      ..moveTo(36, 98)
      ..lineTo(8, 78)
      ..lineTo(22, 98)
      ..lineTo(12, 118)
      ..close();
    canvas.drawPath(tail, darkBlue);

    // Body, rotated -8 degrees around its centre.
    canvas.save();
    canvas.translate(115, 92);
    canvas.rotate(-8 * math.pi / 180);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 144, height: 68), bodyBlue);
    canvas.restore();

    // Belly.
    canvas.save();
    canvas.translate(118, 102);
    canvas.rotate(-8 * math.pi / 180);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 116, height: 40), belly);
    canvas.restore();

    // Dorsal fin.
    final Path dorsal = Path()
      ..moveTo(96, 64)
      ..quadraticBezierTo(102, 38, 120, 56)
      ..quadraticBezierTo(110, 62, 96, 64)
      ..close();
    canvas.drawPath(dorsal, darkBlue);

    // Pectoral fin.
    canvas.save();
    canvas.translate(106, 118);
    canvas.rotate(20 * math.pi / 180);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 32, height: 14), darkBlue);
    canvas.restore();

    // Eye and highlight.
    canvas.drawCircle(const Offset(168, 80), 6, navy);
    canvas.drawCircle(const Offset(170, 78), 2, white);

    // Smile.
    final Path smile = Path()
      ..moveTo(168, 94)
      ..quadraticBezierTo(178, 100, 188, 94);
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF051624)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Cap.
    final Path cap = Path()
      ..moveTo(142, 62)
      ..quadraticBezierTo(150, 38, 172, 40)
      ..quadraticBezierTo(190, 42, 192, 60)
      ..lineTo(184, 63)
      ..quadraticBezierTo(172, 50, 156, 52)
      ..quadraticBezierTo(146, 54, 142, 62)
      ..close();
    canvas.drawPath(cap, purple);

    // Cap brim.
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(188, 61), width: 24, height: 8),
        purple);

    // F on the cap.
    final TextPainter fPainter = TextPainter(
      text: const TextSpan(
        text: 'F',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    fPainter.layout();
    fPainter.paint(canvas, const Offset(166 - 5, 58 - 10));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Finn extends StatelessWidget {
  const Finn({super.key, this.width = 220, this.height = 170});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: FinnPainter()),
    );
  }
}
