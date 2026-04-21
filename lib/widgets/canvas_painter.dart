import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';
import 'package:drawing_app/models/circle_shape.dart';
import 'package:drawing_app/models/ellipse_shape.dart';
import 'package:drawing_app/models/line_shape.dart';
import 'package:drawing_app/models/point_shape.dart';
import 'package:drawing_app/models/rect_shape.dart';
import 'package:drawing_app/models/square_shape.dart';
import 'package:drawing_app/providers/drawing_provider.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  Offset? _startPoint;
  Offset? _currentPoint;

  // Preview khi đang kéo chuột/tay
  BaseShape? _createTempShape(DrawingProvider provider) {
    if (_startPoint == null || _currentPoint == null) return null;

    final color = provider.currentColor;
    final strokeWidth = provider.currentWidth;
    final isFilled = provider.isFilled;

    switch (provider.currentType) {
      case ShapeType.point:
      // Point chỉ vẽ ở điểm hiện tại
        return PointShape(
          color: color,
          strokeWidth: strokeWidth,
          point: _currentPoint!,
        );

      case ShapeType.line:
        return LineShape(
          color: color,
          strokeWidth: strokeWidth,
          start: _startPoint!,
          end: _currentPoint!,
        );

      case ShapeType.rect:
        return RectShape(
          color: color,
          strokeWidth: strokeWidth,
          topLeft: _startPoint!,
          bottomRight: _currentPoint!,
        )..isFilled = isFilled;

      case ShapeType.square:
      // Tính toán cạnh lớn nhất và xử lý việc kéo ngược hướng (lên trên, sang trái)
        final dx = _currentPoint!.dx - _startPoint!.dx;
        final dy = _currentPoint!.dy - _startPoint!.dy;
        final side = math.max(dx.abs(), dy.abs());
        final left = dx < 0 ? _startPoint!.dx - side : _startPoint!.dx;
        final top = dy < 0 ? _startPoint!.dy - side : _startPoint!.dy;

        return SquareShape(
          color: color,
          strokeWidth: strokeWidth,
          topLeft: Offset(left, top),
          side: side,
        )..isFilled = isFilled;

      case ShapeType.ellipse:
        return EllipseShape(
          color: color,
          strokeWidth: strokeWidth,
          bounds: Rect.fromPoints(_startPoint!, _currentPoint!),
        )..isFilled = isFilled;

      case ShapeType.circle:
        final radius = (_currentPoint! - _startPoint!).distance / 2;
        return CircleShape(
          color: color,
          strokeWidth: strokeWidth,
          center: (_startPoint! + _currentPoint!) / 2,
          radius: radius,
        )..isFilled = isFilled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrawingProvider>();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        // Chỉ bắt đầu vẽ nếu không ở chế độ pick màu
        if (provider.isPickingColor) return;

        setState(() {
          _startPoint = details.localPosition;
          _currentPoint = details.localPosition;
        });
      },
      onPanUpdate: (details) {
        if (provider.isPickingColor) return;

        setState(() {
          _currentPoint = details.localPosition;
        });
      },
      onPanEnd: (details) {
        if (provider.isPickingColor) return;

        if (_startPoint != null && _currentPoint != null) {
          final newShape = _createTempShape(provider);
          if (newShape != null) {
            // lưu hình
            provider.add(newShape);
          }
        }
        setState(() {
          _startPoint = null;
          _currentPoint = null;
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: AppCanvasPainter(
          shapes: provider.shapes,
          tempShape: _createTempShape(provider),
        ),
      ),
    );
  }
}

class AppCanvasPainter extends CustomPainter {
  final List<BaseShape> shapes;
  final BaseShape? tempShape;

  AppCanvasPainter({required this.shapes, this.tempShape});

  @override
  void paint(Canvas canvas, Size size) {
    // Để canvas không bị tràn viền
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Vẽ toàn bộ các hình đã lưu
    for (final shape in shapes) {
      shape.draw(canvas);
    }

    // Vẽ hình đang thao tác (nếu có) đè lên trên cùng
    if (tempShape != null) {
      tempShape!.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant AppCanvasPainter oldDelegate) {
    // Luôn vẽ lại khi có update
    return true;
  }
}