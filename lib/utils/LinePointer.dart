import 'package:flutter/material.dart';

class LineChartPainter extends CustomPainter {
  final Color color;
  final List<double> points;

  LineChartPainter({required this.color, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return; // Prevent painting if size is invalid

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Smooth ends

    final path = Path();
    final double step = size.width / (points.length - 1); // Space between points
    final double heightScale = size.height; // Use full height for scaling

    // Start at the first point
    path.moveTo(0, heightScale - (points[0] * heightScale).clamp(0.0, heightScale));

    // Draw lines between points
    for (int i = 1; i < points.length; i++) {
      final x = i * step;
      final y = heightScale - (points[i] * heightScale).clamp(0.0, heightScale); // Keep within bounds
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.points != points;
  }
}