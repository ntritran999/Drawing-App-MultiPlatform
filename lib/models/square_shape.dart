import 'dart:ui';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';

class SquareShape extends BaseShape {
  Offset topLeft;
  double side;
  @override
  ShapeType get type => ShapeType.square;

  SquareShape({
    required super.color,
    required super.strokeWidth,
    required this.topLeft,
    required this.side
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    Offset bottomRight = Offset(topLeft.dx + side, topLeft.dy + side);
    Rect rect = Rect.fromPoints(topLeft, bottomRight);
    canvas.drawRect(rect, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'x': topLeft.dx,
      'y': topLeft.dy,
      'side': side,
    };
  }
}