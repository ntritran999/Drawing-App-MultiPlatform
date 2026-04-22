import 'dart:typed_data';
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
    required this.radius,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'centerX': center.dx,
      'centerY': center.dy,
      'radius': radius,
    };
  }

  @override
  int getShapeDataSize() => 24; // centerX(8) + centerY(8) + radius(8)

  @override
  void writeBinaryData(ByteData byteData, int offset) {
    byteData.setFloat64(offset, center.dx, Endian.little);
    byteData.setFloat64(offset + 8, center.dy, Endian.little);
    byteData.setFloat64(offset + 16, radius, Endian.little);
  }

  static BaseShape? fromBinary(Uint8List data, int offset) {
    if (offset + 34 > data.length) return null;

    ByteData byteData = ByteData.sublistView(data);
    int pos = offset;

    int typeIndex = byteData.getUint8(pos);
    if (typeIndex != ShapeType.circle.index) return null;
    pos += 1;

    Color color = Color(byteData.getUint32(pos, Endian.little));
    pos += 4;

    double strokeWidth = byteData.getFloat32(pos, Endian.little);
    pos += 4;

    bool isFilled = byteData.getUint8(pos) == 1;
    pos += 1;

    double centerX = byteData.getFloat64(pos, Endian.little);
    double centerY = byteData.getFloat64(pos + 8, Endian.little);
    double radius = byteData.getFloat64(pos + 16, Endian.little);

    return CircleShape(
      color: color,
      strokeWidth: strokeWidth,
      center: Offset(centerX, centerY),
      radius: radius,
    )..isFilled = isFilled;
  }
}
