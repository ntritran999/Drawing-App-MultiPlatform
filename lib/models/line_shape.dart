import 'dart:typed_data';
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
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawLine(start, end, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'x1': start.dx,
      'y1': start.dy,
      'x2': end.dx,
      'y2': end.dy,
    };
  }

  @override
  int getShapeDataSize() => 32; // x1(8) + y1(8) + x2(8) + y2(8)

  @override
  void writeBinaryData(ByteData byteData, int offset) {
    byteData.setFloat64(offset, start.dx, Endian.little);
    byteData.setFloat64(offset + 8, start.dy, Endian.little);
    byteData.setFloat64(offset + 16, end.dx, Endian.little);
    byteData.setFloat64(offset + 24, end.dy, Endian.little);
  }

  static BaseShape? fromBinary(Uint8List data, int offset) {
    if (offset + 42 > data.length) return null;

    ByteData byteData = ByteData.sublistView(data);
    int pos = offset;

    int typeIndex = byteData.getUint8(pos);
    if (typeIndex != ShapeType.line.index) return null;
    pos += 1;

    Color color = Color(byteData.getUint32(pos, Endian.little));
    pos += 4;

    double strokeWidth = byteData.getFloat32(pos, Endian.little);
    pos += 4;

    bool isFilled = byteData.getUint8(pos) == 1;
    pos += 1;

    double x1 = byteData.getFloat64(pos, Endian.little);
    double y1 = byteData.getFloat64(pos + 8, Endian.little);
    double x2 = byteData.getFloat64(pos + 16, Endian.little);
    double y2 = byteData.getFloat64(pos + 24, Endian.little);

    return LineShape(
      color: color,
      strokeWidth: strokeWidth,
      start: Offset(x1, y1),
      end: Offset(x2, y2),
    )..isFilled = isFilled;
  }
}