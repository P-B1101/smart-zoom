import 'dart:math';

extension DoubleExt on double {
  double toRadians() => this * pi / 180;

  double getCleanDouble() => double.parse(toStringAsFixed(1));
}

extension ListDoubleExt on List<double> {
  double getNearestValue(double target) => reduce((a, b) => (a - target).abs() < (b - target).abs() ? a : b);
}
