import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerBracketsPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  static const double _padding = 24;
  static const double _cornerLen = 32;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromLTWH(
      _padding,
      _padding,
      size.width - _padding * 2,
      size.height - _padding * 2,
    );

    final p = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tl = box.topLeft;
    final tr = box.topRight;
    final bl = box.bottomLeft;
    final br = box.bottomRight;
    const d = _cornerLen;

    canvas.drawLine(tl, tl + const Offset(d, 0), p);
    canvas.drawLine(tl, tl + const Offset(0, d), p);

    canvas.drawLine(tr, tr + const Offset(-d, 0), p);
    canvas.drawLine(tr, tr + const Offset(0, d), p);

    canvas.drawLine(bl, bl + const Offset(d, 0), p);
    canvas.drawLine(bl, bl + const Offset(0, -d), p);

    canvas.drawLine(br, br + const Offset(-d, 0), p);
    canvas.drawLine(br, br + const Offset(0, -d), p);
  }

  @override
  bool shouldRepaint(_CornerBracketsPainter old) => false;
}
