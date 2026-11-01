import 'package:flutter/cupertino.dart';

/// The back's offset scale as printed on the test sheet, with the front's
/// cross showing through: here 1 mm lower, which is read as Y = +1.
class CalibrationIllustration extends StatelessWidget {
  const CalibrationIllustration({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(200, 140),
    painter: _ScalePainter(
      line: CupertinoColors.label.resolveFrom(context),
      cross: CupertinoColors.systemRed.resolveFrom(context),
    ),
  );
}

class _ScalePainter extends CustomPainter {
  _ScalePainter({required this.line, required this.cross});

  final Color line;
  final Color cross;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const mm = 12.0;
    final scale = Paint()
      ..color = line
      ..strokeWidth = 1;
    canvas
      ..drawLine(c.translate(-5 * mm, 0), c.translate(5 * mm, 0), scale)
      ..drawLine(c.translate(0, -5 * mm), c.translate(0, 5 * mm), scale);
    for (var half = -10; half <= 10; half++) {
      if (half == 0) continue;
      final d = half * mm / 2;
      final length = half.isOdd ? 3.0 : 6.0;
      canvas
        ..drawLine(
          c.translate(d, -length / 2),
          c.translate(d, length / 2),
          scale,
        )
        ..drawLine(
          c.translate(-length / 2, d),
          c.translate(length / 2, d),
          scale,
        );
    }
    // The front's cross, seen through the paper.
    final front = Paint()
      ..color = cross.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    final at = c.translate(0, 1 * mm);
    canvas
      ..drawLine(at.translate(-3.5 * mm, 0), at.translate(3.5 * mm, 0), front)
      ..drawLine(at.translate(0, -3.5 * mm), at.translate(0, 3.5 * mm), front)
      ..drawCircle(
        at,
        mm,
        Paint()
          ..color = cross.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  @override
  bool shouldRepaint(_ScalePainter old) =>
      old.line != line || old.cross != cross;
}
