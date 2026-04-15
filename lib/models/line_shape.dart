import 'dart:ui';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';

class LineShape extends BaseShape {
  Offset start, end;
  @override
  ShapeType get type => ShapeType.line;

  LineShape({
    required super.color,
    required super.strokeWidth,
    required this.start,
    required this.end
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawLine(start, end, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'x1': start.dx,
      'y1': start.dy,
      'x2': end.dx,
      'y2': end.dy,
    };
  }
}