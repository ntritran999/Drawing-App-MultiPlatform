import 'dart:ui';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';

class RectShape extends BaseShape{
  Offset topLeft, bottomRight;
  @override
  ShapeType get type => ShapeType.rect;

  RectShape({
    required super.color,
    required super.strokeWidth,
    required this.topLeft,
    required this.bottomRight
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    Rect rect = Rect.fromPoints(topLeft, bottomRight);
    canvas.drawRect(rect, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'x1': topLeft.dx,
      'y1': topLeft.dy,
      'x2': bottomRight.dx,
      'y2': bottomRight.dy,
    };
  }
}