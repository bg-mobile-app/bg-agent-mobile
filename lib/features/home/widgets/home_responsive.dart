import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeResponsive {
  HomeResponsive._(this.width)
      : scale = (width / 390).clamp(0.78, 1.08).toDouble(),
        textScale = (width / 390).clamp(0.82, 1.0).toDouble();

  factory HomeResponsive.of(BuildContext context) {
    return HomeResponsive._(MediaQuery.of(context).size.width);
  }

  factory HomeResponsive.fromWidth(double width) {
    return HomeResponsive._(width);
  }

  final double width;
  final double scale;
  final double textScale;

  bool get isTightPhone => width < 360;

  double size(double value, {double? min, double? max}) {
    final scaled = value * scale;
    return math
        .min(max ?? double.infinity, math.max(min ?? 0, scaled))
        .toDouble();
  }

  double font(double value, {double? min, double? max}) {
    final scaled = value * textScale;
    return math
        .min(max ?? double.infinity, math.max(min ?? 0, scaled))
        .toDouble();
  }
}
