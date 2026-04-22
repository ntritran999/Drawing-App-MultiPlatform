import 'dart:typed_data';
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

  @override
  int getShapeDataSize() => 24; // x(8) + y(8) + side(8)

  @override
  void writeBinaryData(ByteData byteData, int offset) {
    byteData.setFloat64(offset, topLeft.dx, Endian.little);
    byteData.setFloat64(offset + 8, topLeft.dy, Endian.little);
    byteData.setFloat64(offset + 16, side, Endian.little);
  }

  static BaseShape? fromBinary(Uint8List data, int offset) {
    if (offset + 34 > data.length) return null;

    ByteData byteData = ByteData.sublistView(data);
    int pos = offset;

    int typeIndex = byteData.getUint8(pos);
    if (typeIndex != ShapeType.square.index) return null;
    pos += 1;

    Color color = Color(byteData.getUint32(pos, Endian.little));
    pos += 4;

    double strokeWidth = byteData.getFloat32(pos, Endian.little);
    pos += 4;

    bool isFilled = byteData.getUint8(pos) == 1;
    pos += 1;

    double x = byteData.getFloat64(pos, Endian.little);
    double y = byteData.getFloat64(pos + 8, Endian.little);
    double side = byteData.getFloat64(pos + 16, Endian.little);

    return SquareShape(
      color: color,
      strokeWidth: strokeWidth,
      topLeft: Offset(x, y),
      side: side,
    )..isFilled = isFilled;
  }
}