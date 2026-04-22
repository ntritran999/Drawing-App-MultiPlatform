import 'dart:typed_data';
import 'dart:ui';

import 'package:drawing_app/core/constants.dart';

abstract class BaseShape {
  ShapeType get type;
  Color color;
  double strokeWidth;
  bool isFilled;

  BaseShape({
    required this.color,
    required this.strokeWidth,
    this.isFilled = false,
  });

  void draw(Canvas canvas);

  Map<String, dynamic> toRawData() { // Type -> Color -> StrokeWidth -> IsFilled -> Coords
    return {
      'type': type.index,
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
      'isFilled': isFilled,
    };
  }

  Uint8List toBinary() {
    ByteData byteData = ByteData(getBinarySize());
    int offset = 0;

    byteData.setUint8(offset, type.index);
    offset += 1;

    byteData.setUint32(offset, color.toARGB32(), Endian.little);
    offset += 4;

    byteData.setFloat32(offset, strokeWidth, Endian.little);
    offset += 4;

    byteData.setUint8(offset, isFilled ? 1 : 0);
    offset += 1;

    writeBinaryData(byteData, offset);

    return byteData.buffer.asUint8List();
  }

  int getBinarySize() {
    return 10 + getShapeDataSize(); // 1 + 4 + 4 + 1 
  }

  int getShapeDataSize() => 0;

  void writeBinaryData(ByteData byteData, int offset) {}
}