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
    required this.radius
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