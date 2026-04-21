import 'dart:ui' as ui;

import 'package:drawing_app/models/base_shape.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

enum ExportImageFormat { png, jpeg }

class ExportPayload {
  final Uint8List bytes;
  final String extension;
  final String mimeType;

  const ExportPayload({
    required this.bytes,
    required this.extension,
    required this.mimeType,
  });
}

class ExportService {
  bool get isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<ExportPayload> renderShapes({
    required List<BaseShape> shapes,
    required Size canvasSize,
    required ExportImageFormat format,
    Color backgroundColor = Colors.white,
    double pixelRatio = 1,
    int jpegQuality = 90,
  }) async {
    if (canvasSize.isEmpty) {
      throw ArgumentError('Canvas size must be greater than zero.');
    }
    if (pixelRatio <= 0) {
      throw ArgumentError('Pixel ratio must be greater than zero.');
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final width = (canvasSize.width * pixelRatio).round().clamp(1, 100000);
    final height = (canvasSize.height * pixelRatio).round().clamp(1, 100000);

    canvas.scale(pixelRatio, pixelRatio);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    for (final shape in shapes) {
      shape.draw(canvas);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    if (format == ExportImageFormat.png) {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) {
        throw StateError('Failed to encode PNG image.');
      }

      return ExportPayload(
        bytes: byteData.buffer.asUint8List(),
        extension: 'png',
        mimeType: 'image/png',
      );
    }

    final pngByteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (pngByteData == null) {
      throw StateError('Failed to encode image for JPEG conversion.');
    }

    final decoded = img.decodeImage(pngByteData.buffer.asUint8List());
    if (decoded == null) {
      throw StateError('Failed to decode temporary PNG image.');
    }

    final quality = jpegQuality.clamp(1, 100);
    return ExportPayload(
      bytes: Uint8List.fromList(img.encodeJpg(decoded, quality: quality)),
      extension: 'jpg',
      mimeType: 'image/jpeg',
    );
  }

  Future<String?> saveWithDialog({
    required ExportPayload payload,
    required String suggestedName,
  }) async {
    final saveLocation = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [
        XTypeGroup(label: 'Image', extensions: [payload.extension]),
      ],
    );

    if (saveLocation == null) {
      return null;
    }

    final file = XFile.fromData(
      payload.bytes,
      mimeType: payload.mimeType,
      name: suggestedName,
    );

    await file.saveTo(saveLocation.path);
    return saveLocation.path;
  }

  Future<String?> saveToGallery({
    required ExportPayload payload,
    required String suggestedName,
  }) async {
    if (!isMobilePlatform) {
      throw UnsupportedError('Gallery export is only supported on mobile.');
    }

    final quality = payload.extension == 'jpg' ? 90 : 100;
    final result = await ImageGallerySaverPlus.saveImage(
      payload.bytes,
      quality: quality,
      name: _sanitizeFileName(suggestedName),
      isReturnImagePathOfIOS: true,
    );

    final data = _normalizeResultMap(result);
    final success = data['isSuccess'] ?? data['success'];
    final isSuccess =
        success == true || success == 1 || success?.toString() == '1';

    if (!isSuccess) {
      final error = data['errorMessage'] ?? data['message'] ?? result;
      throw StateError('Failed to save image to gallery: $error');
    }

    final path =
        data['filePath'] ??
        data['savedFilePath'] ??
        data['path'] ??
        data['uri'];

    return path?.toString();
  }

  Map<String, dynamic> _normalizeResultMap(dynamic value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry('$key', value));
    }

    return {};
  }

  String _sanitizeFileName(String name) {
    final dotIndex = name.lastIndexOf('.');
    final fileName = dotIndex <= 0 ? name : name.substring(0, dotIndex);
    return fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
