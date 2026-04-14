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
    // TODO: implement draw
  }

  @override
  Map<String, dynamic> toRawData() {
    // TODO: implement toRawData
    throw UnimplementedError();
  }
}