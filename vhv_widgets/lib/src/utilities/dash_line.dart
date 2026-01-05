import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedLine({
    super.key,
    this.height = 1.0,
    this.color = Colors.black,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.width = 30,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(color, height, dashWidth, dashSpace),
      child: SizedBox(
        height: height,
        width: width,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double height;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter(this.color, this.height, this.dashWidth, this.dashSpace);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = height;

    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
