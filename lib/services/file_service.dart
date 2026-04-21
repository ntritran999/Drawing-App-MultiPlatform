import 'dart:convert';
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
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FileService {
  Uint8List convertShapesToBinary(List<BaseShape> shapes) {
    List<Map<String, dynamic>> rawList = shapes
        .map((s) => s.toRawData())
        .toList();
    String jsonString = jsonEncode(rawList);
    return utf8.encode(jsonString);
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

    File file = File(outputFile);
    await file.writeAsBytes(binaryData);
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

    String? filePath = result.files.single.path;
    if (filePath == null) return [];

    String jsonString = "";

    if (kIsWeb) {
      PlatformFile file = result.files.first;
      if(file.bytes == null) return [];
      jsonString = utf8.decode(file.bytes!);
    } else {
      File file = File(filePath);
      if (!await file.exists()) {
        return [];
      }

      Uint8List binaryData = await file.readAsBytes();
      jsonString = utf8.decode(binaryData);
    }
    
    List<dynamic> rawList = jsonDecode(jsonString);
    return rawList.map((data) => _parseShape(data)).toList();
  }

  BaseShape _parseShape(Map<String, dynamic> data) {
    ShapeType type = ShapeType.values[data['type'] as int];
    Color color = Color(data['color'] as int);
    double strokeWidth = (data['strokeWidth'] as num).toDouble();
    bool isFilled = data['isFilled'] as bool? ?? false;

    switch (type) {
      case ShapeType.point:
        return PointShape(
          color: color,
          strokeWidth: strokeWidth,
          point: Offset(
            (data['x'] as num).toDouble(),
            (data['y'] as num).toDouble(),
          ),
        )..isFilled = isFilled;
      case ShapeType.line:
        return LineShape(
          color: color,
          strokeWidth: strokeWidth,
          start: Offset(
            (data['x1'] as num).toDouble(),
            (data['y1'] as num).toDouble(),
          ),
          end: Offset(
            (data['x2'] as num).toDouble(),
            (data['y2'] as num).toDouble(),
          ),
        )..isFilled = isFilled;
      case ShapeType.circle:
        final centerX = (data['centerX'] ?? data['x']) as num;
        final centerY = (data['centerY'] ?? data['y']) as num;

        return CircleShape(
          color: color,
          strokeWidth: strokeWidth,
          center: Offset(centerX.toDouble(), centerY.toDouble()),
          radius: (data['radius'] as num).toDouble(),
        )..isFilled = isFilled;
      case ShapeType.square:
        return SquareShape(
          color: color,
          strokeWidth: strokeWidth,
          topLeft: Offset(
            (data['x'] as num).toDouble(),
            (data['y'] as num).toDouble(),
          ),
          side: (data['side'] as num).toDouble(),
        )..isFilled = isFilled;
      case ShapeType.rect:
        return RectShape(
          color: color,
          strokeWidth: strokeWidth,
          topLeft: Offset(
            (data['x1'] as num).toDouble(),
            (data['y1'] as num).toDouble(),
          ),
          bottomRight: Offset(
            (data['x2'] as num).toDouble(),
            (data['y2'] as num).toDouble(),
          ),
        )..isFilled = isFilled;
      case ShapeType.ellipse:
        return EllipseShape(
          color: color,
          strokeWidth: strokeWidth,
          bounds: Rect.fromLTRB(
            (data['left'] as num).toDouble(),
            (data['top'] as num).toDouble(),
            (data['right'] as num).toDouble(),
            (data['bottom'] as num).toDouble(),
          ),
        )..isFilled = isFilled;
    }
  }
}
