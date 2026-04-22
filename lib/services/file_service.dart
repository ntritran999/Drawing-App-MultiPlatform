import 'dart:io';
import 'dart:typed_data';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';
import 'package:drawing_app/models/circle_shape.dart';
import 'package:drawing_app/models/ellipse_shape.dart';
import 'package:drawing_app/models/line_shape.dart';
import 'package:drawing_app/models/point_shape.dart';
import 'package:drawing_app/models/rect_shape.dart';
import 'package:drawing_app/models/square_shape.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FileService {
  Uint8List convertShapesToBinary(List<BaseShape> shapes) {
    int totalSize = 4;
    for (var shape in shapes) {
      totalSize += shape.toBinary().length;
    }

    ByteData byteData = ByteData(totalSize);
    int offset = 0;

    // Write length of shapes
    byteData.setUint32(offset, shapes.length, Endian.little);
    offset += 4;

    // Write each shape
    for (var shape in shapes) {
      Uint8List shapeData = shape.toBinary();
      for (int i = 0; i < shapeData.length; i++) {
        byteData.setUint8(offset + i, shapeData[i]);
      }
      offset += shapeData.length;
    }

    return byteData.buffer.asUint8List();
  }

  Future<String?> saveFile(List<BaseShape> shapes) async {
    Uint8List binaryData = convertShapesToBinary(shapes);

    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save Drawing',
      fileName: 'drawing.bin',
      bytes: binaryData
    );

    if (outputFile == null) {
      return null;
    }

    return outputFile;
  }

  Future<List<BaseShape>> loadFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['bin'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return [];

    Uint8List binaryData;

    if (kIsWeb) {
      PlatformFile file = result.files.first;
      if (file.bytes == null) return [];
      binaryData = file.bytes!;
    } else {
      String? filePath = result.files.single.path;
      if (filePath == null) return [];

      File file = File(filePath);
      if (!await file.exists()) {
        return [];
      }

      binaryData = await file.readAsBytes();
    }

    return _parseBinaryData(binaryData);
  }

  List<BaseShape> _parseBinaryData(Uint8List data) {
    if (data.length < 4) return [];

    ByteData byteData = ByteData.sublistView(data);
    int offset = 0;

    // Read shape count
    int shapeCount = byteData.getUint32(offset, Endian.little);
    offset += 4;

    List<BaseShape> shapes = [];
    for (int i = 0; i < shapeCount; i++) {
      if (offset >= byteData.lengthInBytes) break;
      
      BaseShape? shape = _readShape(byteData, offset);
      if (shape != null) {
        shapes.add(shape);
        offset += shape.getBinarySize();
      } else {
        break;
      }
    }

    return shapes;
  }


  BaseShape? _readShape(ByteData byteData, int offset) {
    if (offset + 1 > byteData.lengthInBytes) return null;

    int typeIndex = byteData.getUint8(offset);
    if (typeIndex >= ShapeType.values.length) return null;

    switch (ShapeType.values[typeIndex]) {
      case ShapeType.point:
        return PointShape.fromBinary(byteData.buffer.asUint8List(), offset);
      case ShapeType.line:
        return LineShape.fromBinary(byteData.buffer.asUint8List(), offset);
      case ShapeType.circle:
        return CircleShape.fromBinary(byteData.buffer.asUint8List(), offset);
      case ShapeType.square:
        return SquareShape.fromBinary(byteData.buffer.asUint8List(), offset);
      case ShapeType.rect:
        return RectShape.fromBinary(byteData.buffer.asUint8List(), offset);
      case ShapeType.ellipse:
        return EllipseShape.fromBinary(byteData.buffer.asUint8List(), offset);
    }
  }
}
