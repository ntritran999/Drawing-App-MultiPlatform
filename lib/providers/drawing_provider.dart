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

  void add(BaseShape shape) {
    _shapes.add(shape);
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