import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 220,
  });

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..color = const Color(0x66FFFFFF);

    canvas.drawCircle(center, radius - 8, bgPaint);

    final clamped = progress.clamp(0.0, 1.0);
    if (clamped <= 0) {
      return;
    }
    final sweep = (clamped) * 6.28318;
    final safeSweep = sweep < 0.001 ? 0.001 : sweep;
    final gradient = SweepGradient(
      startAngle: -1.5708,
      endAngle: -1.5708 + safeSweep,
      colors: const [Color(0xFFDDE3FF), Color(0xFFF3E8FF)],
    );

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -1.5708,
      -safeSweep,
      false,
      fgPaint,
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..color = const Color(0x55FFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -1.5708,
      -safeSweep,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
