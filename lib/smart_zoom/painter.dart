import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'extension.dart';

class DialPainter extends CustomPainter {
  final Color color;
  final Color activeColor;
  final List<double> numbers;
  final TextSpan Function(double value) valueBuilder;
  final double currentValue;

  const DialPainter({
    required this.numbers,
    required this.valueBuilder,
    required this.color,
    required this.activeColor,
    required this.currentValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = math.min(size.width, size.height) / 2;
    canvas.translate(size.width / 2, size.height / 2);
    _drawMarkings(canvas, radius);
    _drawNumbers(canvas, radius * .8);
  }

  void _drawMarkings(final Canvas canvas, final double radius) {
    double r = radius;
    double len = 15;
    double p = len + 4;
    Paint tickPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0;

    for (int i = 0; i < numbers.length; i++) {
      final isMainValue = _isMainValue(i);
      tickPaint.color =
          (numbers[i].getCleanDouble() == currentValue.getCleanDouble() ? activeColor : color).withOpacity(isMainValue ? 1 : .25);
      double angleFrom12 = (i * 2.5).toRadians();
      double angleFrom3 = angleFrom12 - 90.0.toRadians();
      final offset1 = Offset(math.cos(angleFrom3) * (r + len - p), math.sin(angleFrom3) * (r + len - p));
      final offset2 = Offset(math.cos(angleFrom3) * (r - p), math.sin(angleFrom3) * (r - p));

      canvas.drawLine(offset1, offset2, tickPaint);
    }
  }

  void _drawNumbers(final Canvas canvas, final double radius) {
    double r = radius;
    double len = 15;
    double p = len + 4;

    for (int i = 0; i < numbers.length; i++) {
      if (!_isMainValue(i)) continue;
      if (_isAroundValue(currentValue, numbers[i])) continue;
      double angleFrom12 = (i * 2.5).toRadians();
      double angleFrom3 = angleFrom12 - 90.0.toRadians();
      final offset = Offset(math.cos(angleFrom3) * (r + len - p), math.sin(angleFrom3) * (r + len - p));
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: valueBuilder(numbers[i]),
      )..layout();
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angleFrom12);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant DialPainter oldDelegate) {
    return oldDelegate.numbers != numbers ||
        oldDelegate.color != color ||
        oldDelegate.currentValue != currentValue ||
        oldDelegate.activeColor != activeColor;
  }

  double get _min => numbers.first;

  double get _max => numbers.last;

  bool _isMainValue(int index) =>
      numbers[index] == _min || numbers[index] == _max || numbers[index].floorToDouble() == numbers[index];

  bool _isAroundValue(double current, double target) {
    final lower = target - .45;
    final upper = target + .45;
    return current >= lower && current <= upper;
  }
}
