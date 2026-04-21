import 'package:drawing_app/models/base_shape.dart';
import 'package:drawing_app/services/file_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:drawing_app/core/constants.dart';
import 'package:drawing_app/providers/drawing_provider.dart';
import 'package:drawing_app/widgets/color_picker.dart';

class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({super.key, this.onExport});

  final Future<void> Function()? onExport;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawing, _) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white38,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        onPressed: drawing.shapes.isNotEmpty
                            ? drawing.undo
                            : null,
                        icon: const Icon(Icons.undo, size: 18),
                        label: const Text(
                          'Undo',
                          style: TextStyle(fontSize: 13),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          foregroundColor: Colors.red[300],
                          disabledForegroundColor: Colors.white38,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        onPressed: drawing.shapes.isNotEmpty
                            ? drawing.clear
                            : null,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text(
                          'Clear All',
                          style: TextStyle(fontSize: 13),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ShapesSection(
                        currentType: drawing.currentType,
                        onSelected: drawing.setShapeType,
                      ),
                      const Divider(height: 24, color: Colors.white24),
                      _StyleSection(
                        selectedColor: drawing.currentColor,
                        strokeWidth: drawing.currentWidth,
                        isFilled: drawing.isFilled,
                        onColorChanged: drawing.setColor,
                        onStrokeChanged: drawing.setStrokeWidth,
                        onFillChanged: drawing.setIsFilled,
                      ),
                      const Divider(height: 24, color: Colors.white24),
                      _ActionsSection(onExport: onExport),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShapesSection extends StatelessWidget {
  const _ShapesSection({required this.currentType, required this.onSelected});

  final ShapeType currentType;
  final ValueChanged<ShapeType> onSelected;

  static const List<_ShapeItem> _items = [
    _ShapeItem(type: ShapeType.point, label: 'Point', icon: Icons.circle),
    _ShapeItem(type: ShapeType.line, label: 'Line', icon: Icons.show_chart),
    _ShapeItem(type: ShapeType.rect, label: 'Rectangle', icon: Icons.crop_16_9),
    _ShapeItem(
      type: ShapeType.square,
      label: 'Square',
      icon: Icons.crop_square,
    ),
    _ShapeItem(
      type: ShapeType.circle,
      label: 'Circle',
      icon: Icons.radio_button_unchecked,
    ),
    _ShapeItem(
      type: ShapeType.ellipse,
      label: 'Ellipse',
      icon: IconData(0x2B2D, fontFamily: "MaterialIcons"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Shapes'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _items
              .map(
                (item) => SizedBox(
                  width: 92,
                  child: _ShapeButton(
                    item: item,
                    isSelected: currentType == item.type,
                    onPressed: () => onSelected(item.type),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StyleSection extends StatelessWidget {
  const _StyleSection({
    required this.selectedColor,
    required this.strokeWidth,
    required this.isFilled,
    required this.onColorChanged,
    required this.onStrokeChanged,
    required this.onFillChanged,
  });

  final Color selectedColor;
  final double strokeWidth;
  final bool isFilled;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onStrokeChanged;
  final ValueChanged<bool> onFillChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Style'),
        const SizedBox(height: 10),
        ColorPickerButton(
          selectedColor: selectedColor,
          onChanged: onColorChanged,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Stroke width',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              strokeWidth.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Slider(
          value: strokeWidth.clamp(1, 20),
          min: 1,
          max: 20,
          divisions: 38,
          label: strokeWidth.toStringAsFixed(1),
          onChanged: onStrokeChanged,
        ),
        SwitchListTile.adaptive(
          value: isFilled,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Fill shape',
            style: TextStyle(color: Colors.white),
          ),
          onChanged: onFillChanged,
        ),
      ],
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({this.onExport});

  final Future<void> Function()? onExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Actions'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () async {
                  final drawingProvider = context.read<DrawingProvider>();
                  final List<BaseShape> shapes = drawingProvider.shapes
                      .toList();
                  final fileService = FileService();

                  String? result = await fileService.saveFile(shapes);
                  if (context.mounted) {
                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved to: $result')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Save cancelled')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.save_alt),
                label: const Text('Save'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () async {
                  final drawingProvider = context.read<DrawingProvider>();
                  final fileService = FileService();
                  List<BaseShape> shapes = await fileService.loadFile();
                  if (context.mounted) {
                    if (shapes.isNotEmpty) {
                      drawingProvider.loadShapes(shapes);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Loaded ${shapes.length} shapes'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No file loaded')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.file_open),
                label: const Text('Load'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            if (onExport != null) {
              await onExport!.call();
              return;
            }

            if (!context.mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Export PNG action is not configured.'),
              ),
            );
          },
          icon: const Icon(Icons.file_upload_outlined),
          label: const Text('Export'),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _ShapeItem {
  const _ShapeItem({
    required this.type,
    required this.label,
    required this.icon,
  });

  final ShapeType type;
  final String label;
  final IconData icon;
}

class _ShapeButton extends StatelessWidget {
  const _ShapeButton({
    required this.item,
    required this.isSelected,
    required this.onPressed,
  });

  final _ShapeItem item;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? Colors.blue.shade300 : Colors.white10;
    final foreground = isSelected ? Colors.black : Colors.white;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 24, color: foreground),
              const SizedBox(height: 6),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
