import 'dart:typed_data';
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
    required this.bounds,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawOval(bounds, paint);
  }

  @override
  Map<String, dynamic> toRawData() {
    return {
      ...super.toRawData(),
      'left': bounds.left,
      'top': bounds.top,
      'right': bounds.right,
      'bottom': bounds.bottom,
    };
  }

  @override
  int getShapeDataSize() => 32; // left(8) + top(8) + right(8) + bottom(8)

  @override
  void writeBinaryData(ByteData byteData, int offset) {
    byteData.setFloat64(offset, bounds.left, Endian.little);
    byteData.setFloat64(offset + 8, bounds.top, Endian.little);
    byteData.setFloat64(offset + 16, bounds.right, Endian.little);
    byteData.setFloat64(offset + 24, bounds.bottom, Endian.little);
  }

  static BaseShape? fromBinary(Uint8List data, int offset) {
    if (offset + 42 > data.length) return null;

    ByteData byteData = ByteData.sublistView(data);
    int pos = offset;

    int typeIndex = byteData.getUint8(pos);
    if (typeIndex != ShapeType.ellipse.index) return null;
    pos += 1;

    Color color = Color(byteData.getUint32(pos, Endian.little));
    pos += 4;

    double strokeWidth = byteData.getFloat32(pos, Endian.little);
    pos += 4;

    bool isFilled = byteData.getUint8(pos) == 1;
    pos += 1;

    double left = byteData.getFloat64(pos, Endian.little);
    double top = byteData.getFloat64(pos + 8, Endian.little);
    double right = byteData.getFloat64(pos + 16, Endian.little);
    double bottom = byteData.getFloat64(pos + 24, Endian.little);

    return EllipseShape(
      color: color,
      strokeWidth: strokeWidth,
      bounds: Rect.fromLTRB(left, top, right, bottom),
    )..isFilled = isFilled;
  }
}
