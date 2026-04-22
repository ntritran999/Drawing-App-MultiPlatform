import 'dart:typed_data';
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
    final paint = Paint()
              ..color = color
              ..style = PaintingStyle.fill
              ..isAntiAlias = true;

    canvas.drawCircle(point, strokeWidth, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'x': point.dx,
      'y': point.dy,
    };
  }

  @override
  int getShapeDataSize() => 16; // x(8) + y(8)

  @override
  void writeBinaryData(ByteData byteData, int offset) {
    byteData.setFloat64(offset, point.dx, Endian.little);
    byteData.setFloat64(offset + 8, point.dy, Endian.little);
  }

  static BaseShape? fromBinary(Uint8List data, int offset) {
    if (offset + 26 > data.length) return null; // 10 header + 16 data

    ByteData byteData = ByteData.sublistView(data);
    int pos = offset;

    int typeIndex = byteData.getUint8(pos);
    if (typeIndex != ShapeType.point.index) return null;
    pos += 1;

    Color color = Color(byteData.getUint32(pos, Endian.little));
    pos += 4;

    double strokeWidth = byteData.getFloat32(pos, Endian.little);
    pos += 4;

    bool isFilled = byteData.getUint8(pos) == 1;
    pos += 1;

    double x = byteData.getFloat64(pos, Endian.little);
    double y = byteData.getFloat64(pos + 8, Endian.little);

    return PointShape(
      color: color,
      strokeWidth: strokeWidth,
      point: Offset(x, y),
    )..isFilled = isFilled;
  }
}