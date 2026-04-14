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
    // TODO: implement draw
  }

  @override
  Map<String, dynamic> toRawData() {
    // TODO: implement toRawData
    throw UnimplementedError();
  }
}