import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../render/grid.dart';

/// The steps of the cutting guide.
enum CutStep { edges, columns, rows }

/// An A4 sheet with the card grid; the cuts of [step] are drawn in colour.
class CutIllustration extends StatelessWidget {
  const CutIllustration({super.key, required this.step, this.width = 120});

  final CutStep step;
  final double width;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, width * 297 / 210),
    painter: _CutPainter(
      step,
      line: CupertinoColors.label.resolveFrom(context),
      cut: CupertinoColors.systemRed.resolveFrom(context),
    ),
  );
}

class _CutPainter extends CustomPainter {
  _CutPainter(this.step, {required this.line, required this.cut});

  final CutStep step;
  final Color line;
  final Color cut;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 210;
    const grid = SheetGrid();
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke,
    );
    final thin = Paint()
      ..color = line.withValues(alpha: 0.35)
      ..strokeWidth = 0.6;
    final bold = Paint()
      ..color = cut
      ..strokeWidth = 2;
    final xs = grid.columnEdges();
    final ys = grid.rowEdges();
    void v(double x, Paint p) => canvas.drawLine(
      Offset(x * scale, 0),
      Offset(x * scale, size.height),
      p,
    );
    void h(double y, Paint p) =>
        canvas.drawLine(Offset(0, y * scale), Offset(size.width, y * scale), p);
    for (final x in xs) {
      v(x, thin);
    }
    for (final y in ys) {
      h(y, thin);
    }
    switch (step) {
      case CutStep.edges:
        v(xs.first, bold);
        v(xs.last, bold);
        h(ys.first, bold);
        h(ys.last, bold);
      case CutStep.columns:
        for (final x in xs.sublist(1, xs.length - 1)) {
          v(x, bold);
        }
      case CutStep.rows:
        for (final y in ys.sublist(1, ys.length - 1)) {
          h(y, bold);
        }
    }
  }

  @override
  bool shouldRepaint(_CutPainter old) =>
      old.step != step || old.line != line || old.cut != cut;
}

/// A stack of printed sheets being turned over along the long edge, like
/// the page of a book.
class FlipIllustration extends StatelessWidget {
  const FlipIllustration({super.key, this.width = 180});

  final double width;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, width * 0.7),
    painter: _FlipPainter(
      line: CupertinoColors.label.resolveFrom(context),
      accent: CupertinoTheme.of(context).primaryColor,
    ),
  );
}

class _FlipPainter extends CustomPainter {
  _FlipPainter({required this.line, required this.accent});

  final Color line;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final pageW = size.width * 0.32;
    final pageH = size.height * 0.8;
    final top = size.height * 0.12;
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final fill = Paint()..color = const Color(0xFFFFFFFF);
    final left = Rect.fromLTWH(size.width * 0.08, top, pageW, pageH);
    final right = Rect.fromLTWH(size.width * 0.6, top, pageW, pageH);
    for (final r in [left, right]) {
      canvas
        ..drawRect(r, fill)
        ..drawRect(r, stroke);
    }
    // "1" on the front, "2" on the back.
    final text = TextPainter(textDirection: TextDirection.ltr);
    for (final (r, label) in [(left, '1'), (right, '2')]) {
      text
        ..text = TextSpan(
          text: label,
          style: TextStyle(
            color: const Color(0xFF000000),
            fontSize: pageH * 0.3,
          ),
        )
        ..layout();
      text.paint(canvas, r.center - Offset(text.width / 2, text.height / 2));
    }
    // An arrow over the top, turning like a page around the long edge.
    final arc = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final start = Offset(left.center.dx, top - 2);
    final end = Offset(right.center.dx, top - 2);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(size.width / 2, -size.height * 0.08, end.dx, end.dy);
    canvas.drawPath(path, arc);
    const head = 8.0;
    final angle = math.atan2(
      end.dy - (-size.height * 0.08),
      end.dx - size.width / 2,
    );
    canvas.drawPath(
      Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(
          end.dx - head * math.cos(angle - 0.5),
          end.dy - head * math.sin(angle - 0.5),
        )
        ..moveTo(end.dx, end.dy)
        ..lineTo(
          end.dx - head * math.cos(angle + 0.5),
          end.dy - head * math.sin(angle + 0.5),
        ),
      arc,
    );
  }

  @override
  bool shouldRepaint(_FlipPainter old) =>
      old.line != line || old.accent != accent;
}
