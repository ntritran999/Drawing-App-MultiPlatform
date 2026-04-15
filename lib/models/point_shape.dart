import 'dart:ui';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';

class PointShape extends BaseShape {
  Offset point;
  @override
  ShapeType get type => ShapeType.point;

  PointShape({
    required super.color,
    required super.strokeWidth,
    required this.point
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
              ..color = color
              ..style = PaintingStyle.fill
              ..isAntiAlias = true;

    canvas.drawCircle(point, strokeWidth, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'x': point.dx,
      'y': point.dy,
    };
  }

}