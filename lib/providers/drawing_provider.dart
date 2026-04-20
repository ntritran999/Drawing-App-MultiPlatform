import 'dart:collection';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/models/base_shape.dart';
import 'package:flutter/material.dart';

class DrawingProvider extends ChangeNotifier {
  final List<BaseShape> _shapes = [];
  UnmodifiableListView<BaseShape> get shapes => UnmodifiableListView(_shapes);

  ShapeType currentType = ShapeType.point;
  Color currentColor = Colors.black;
  double currentWidth = 2.0;
  bool isFilled = false;
  bool isPickingColor = false;
  Offset? pickerPosition;

  void add(BaseShape shape) {
    _shapes.add(shape);
    notifyListeners();
  }

  void setShapeType(ShapeType type) {
    if (currentType == type) {
      return;
    }
    currentType = type;
    notifyListeners();
  }

  void setColor(Color color) {
    if (currentColor == color) {
      return;
    }
    currentColor = color;
    notifyListeners();
  }

  void beginColorPick() {
    if (isPickingColor) {
      return;
    }
    isPickingColor = true;
    pickerPosition = null;
    notifyListeners();
  }

  void updatePickerPosition(Offset position) {
    if (!isPickingColor) {
      return;
    }
    pickerPosition = position;
    notifyListeners();
  }

  void cancelColorPick() {
    if (!isPickingColor && pickerPosition == null) {
      return;
    }
    isPickingColor = false;
    pickerPosition = null;
    notifyListeners();
  }

  void completeColorPick(Color color) {
    currentColor = color;
    isPickingColor = false;
    pickerPosition = null;
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    if (currentWidth == width) {
      return;
    }
    currentWidth = width;
    notifyListeners();
  }

  void setIsFilled(bool value) {
    if (isFilled == value) {
      return;
    }
    isFilled = value;
    notifyListeners();
  }

  void undo() {
    if (_shapes.isNotEmpty) {
      _shapes.removeLast();
      notifyListeners();
    }
  }

  void loadShapes(List<BaseShape> shapes) {
    _shapes..clear()..addAll(shapes);
    notifyListeners();
  }
}