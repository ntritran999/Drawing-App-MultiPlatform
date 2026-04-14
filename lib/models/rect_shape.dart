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
    // TODO: implement draw
  }

  @override
  Map<String, dynamic> toRawData() {
    // TODO: implement toRawData
    throw UnimplementedError();
  }
}