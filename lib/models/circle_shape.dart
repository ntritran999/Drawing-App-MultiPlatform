import 'dart:ui';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';

class CircleShape extends BaseShape {
  Offset center;
  double radius;
  @override
  ShapeType get type => ShapeType.circle;

  CircleShape({
    required super.color,
    required super.strokeWidth,
    required this.center,
    required this.radius,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'centerX': center.dx,
      'centerY': center.dy,
      'radius': radius,
    };
  }
}
