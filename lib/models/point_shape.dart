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
    // TODO: implement draw
  }

  @override
  Map<String, dynamic> toRawData() {
    // TODO: implement toRawData
    throw UnimplementedError();
  }

}