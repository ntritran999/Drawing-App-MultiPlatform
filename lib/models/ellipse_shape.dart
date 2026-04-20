import 'dart:ui';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';

class EllipseShape extends BaseShape {
  Rect bounds;
  @override
  ShapeType get type => ShapeType.ellipse;

  EllipseShape({
    required super.color,
    required super.strokeWidth,
    required this.bounds,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawOval(bounds, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'left': bounds.left,
      'top': bounds.top,
      'right': bounds.right,
      'bottom': bounds.bottom,
    };
  }
}
