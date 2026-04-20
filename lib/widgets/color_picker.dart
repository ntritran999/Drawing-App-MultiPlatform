import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:drawing_app/providers/drawing_provider.dart';

class ColorPickerButton extends StatelessWidget {
  const ColorPickerButton({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  final Color selectedColor;
  final ValueChanged<Color> onChanged;

  static const List<Color> _palette = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showPalette(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black26),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Color'),
          const Spacer(),
          IconButton(
            onPressed: () => _startEyedropper(context),
            tooltip: 'Pick color from screen',
            icon: const Icon(Icons.colorize_outlined),
          ),
          const Icon(Icons.expand_more),
        ],
      ),
    );
  }

  void _showPalette(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pick a color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _palette
                      .map(
                        (color) => InkWell(
                          onTap: () {
                            onChanged(color);
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedColor == color ? Colors.blue : Colors.black26,
                                width: selectedColor == color ? 2 : 1,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _showRgbWheelPicker(context),
                    icon: const Icon(Icons.blur_circular_outlined),
                    label: const Text('RGB Wheel Picker'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _startEyedropper(context),
                    icon: const Icon(Icons.colorize_outlined),
                    label: const Text('Use Eyedropper'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startEyedropper(BuildContext context) {
    Navigator.maybePop(context);
    context.read<DrawingProvider>().beginColorPick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Move mouse to a color and click to pick it.')),
    );
  }

  Future<void> _showRgbWheelPicker(BuildContext context) async {
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => _RgbWheelPickerDialog(initialColor: selectedColor),
    );

    if (pickedColor != null) {
      onChanged(pickedColor);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _RgbWheelPickerDialog extends StatefulWidget {
  const _RgbWheelPickerDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_RgbWheelPickerDialog> createState() => _RgbWheelPickerDialogState();
}

class _RgbWheelPickerDialogState extends State<_RgbWheelPickerDialog> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
    if (_hsv.value == 0) {
      _hsv = _hsv.withValue(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _hsv.toColor();
    final hex = selected.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();

    return AlertDialog(
      title: const Text('RGB Wheel Picker'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ColorWheel(
              hue: _hsv.hue,
              saturation: _hsv.saturation,
              value: _hsv.value,
              onChanged: (hue, saturation) {
                setState(() {
                  _hsv = _hsv.withHue(hue).withSaturation(saturation);
                });
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Brightness'),
                Expanded(
                  child: Slider(
                    value: _hsv.value,
                    min: 0,
                    max: 1,
                    onChanged: (value) => setState(() => _hsv = _hsv.withValue(value)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                const SizedBox(width: 8),
                Text('#$hex'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(selected),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _ColorWheel extends StatelessWidget {
  const _ColorWheel({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  final double hue;
  final double saturation;
  final double value;
  final void Function(double hue, double saturation) onChanged;

  @override
  Widget build(BuildContext context) {
    const size = 220.0;
    const radius = size / 2;

    void pickAt(Offset position) {
      final dx = position.dx - radius;
      final dy = position.dy - radius;
      final distance = math.sqrt(dx * dx + dy * dy).clamp(0, radius);
      final newSaturation = (distance / radius).clamp(0.0, 1.0);
      final angle = math.atan2(dy, dx);
      final degrees = (angle * 180 / math.pi + 360) % 360;
      onChanged(degrees, newSaturation);
    }

    return GestureDetector(
      onPanDown: (details) => pickAt(details.localPosition),
      onPanUpdate: (details) => pickAt(details.localPosition),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ColorWheelPainter(hue: hue, saturation: saturation, value: value),
        ),
      ),
    );
  }
}

class _ColorWheelPainter extends CustomPainter {
  _ColorWheelPainter({
    required this.hue,
    required this.saturation,
    required this.value,
  });

  final double hue;
  final double saturation;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final huePaint = Paint()
      ..shader = SweepGradient(
        colors: List<Color>.generate(
          13,
          (index) => HSVColor.fromAHSV(1, index * 30.0, 1, value).toColor(),
        ),
      ).createShader(rect);

    canvas.drawCircle(center, radius, huePaint);

    final whiteBlend = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.transparent],
      ).createShader(rect);
    canvas.drawCircle(center, radius, whiteBlend);

    final markerDistance = saturation * radius;
    final markerAngle = hue * math.pi / 180;
    final marker = Offset(
      center.dx + math.cos(markerAngle) * markerDistance,
      center.dy + math.sin(markerAngle) * markerDistance,
    );

    final markerColor = HSVColor.fromAHSV(1, hue, saturation, value).toColor();
    final markerPaint = Paint()..color = markerColor;
    canvas.drawCircle(marker, 9, markerPaint);
    canvas.drawCircle(
      marker,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black,
    );
    canvas.drawCircle(
      marker,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white70,
    );
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) {
    return oldDelegate.hue != hue ||
        oldDelegate.saturation != saturation ||
        oldDelegate.value != value;
  }
}
