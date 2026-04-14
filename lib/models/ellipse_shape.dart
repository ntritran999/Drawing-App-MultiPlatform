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
    required this.bounds
  });

  @override
  void draw(Canvas canvas) {
    // TODO: implement draw
  }

  @override
  Map<String, dynamic> toRawData() {
    // TODO: implement toRawData
    throw UnimplementedError();
  }
}