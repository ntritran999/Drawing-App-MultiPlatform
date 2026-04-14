import 'dart:ui';

import 'package:drawing_app/core/constants.dart';

abstract class BaseShape {
  ShapeType get type;
  Color color;
  double strokeWidth;
  bool isFilled;

  BaseShape({
    required this.color,
    required this.strokeWidth,
    this.isFilled = false,
  });

  void draw(Canvas canvas);

  Map<String, dynamic> toRawData(); // Type -> Color -> StrokeWidth -> IsFilled -> Coords
}