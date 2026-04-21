import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:drawing_app/providers/drawing_provider.dart';
import 'package:drawing_app/services/export_service.dart';
import 'package:drawing_app/widgets/toolbar.dart';
import 'package:drawing_app/widgets/canvas_painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingProvider(),
      child: MaterialApp(
        title: 'Flutter Draw',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const DrawingPage(),
      ),
    );
  }
}

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _captureKey = GlobalKey();
  final ExportService _exportService = ExportService();

  String _buildExportFileName(ExportImageFormat format) {
    final now = DateTime.now();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final extension = format == ExportImageFormat.png ? 'png' : 'jpg';

    return 'drawing_${now.year}${twoDigits(now.month)}${twoDigits(now.day)}_'
        '${twoDigits(now.hour)}${twoDigits(now.minute)}${twoDigits(now.second)}.$extension';
  }

  Future<void> _exportDrawing(ExportImageFormat format) async {
    final messenger = ScaffoldMessenger.of(context);
    final drawing = context.read<DrawingProvider>();
    if (drawing.shapes.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Canvas is empty, nothing to export.')),
      );
      return;
    }

    final boundaryContext = _captureKey.currentContext;
    final canvasSize = boundaryContext?.size ?? MediaQuery.of(context).size;

    if (canvasSize.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to detect canvas size for export.'),
        ),
      );
      return;
    }

    try {
      final payload = await _exportService.renderShapes(
        shapes: drawing.shapes.toList(),
        canvasSize: canvasSize,
        format: format,
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      final suggestedName = _buildExportFileName(format);

      if (_exportService.isMobilePlatform) {
        final savedPath = await _exportService.saveToGallery(
          payload: payload,
          suggestedName: suggestedName,
        );

        if (!mounted) {
          return;
        }

        if (savedPath == null || savedPath.isEmpty) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Exported image to gallery.')),
          );
          return;
        }

        messenger.showSnackBar(
          SnackBar(content: Text('Exported image to gallery: $savedPath')),
        );
        return;
      }

      final savedPath = await _exportService.saveWithDialog(
        payload: payload,
        suggestedName: suggestedName,
      );

      if (!mounted) {
        return;
      }

      if (savedPath == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Export canceled.')),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text('Exported image to: $savedPath')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  Future<void> _pickColorAt(Offset localPosition) async {
    final drawing = context.read<DrawingProvider>();
    final boundaryContext = _captureKey.currentContext;
    if (boundaryContext == null) {
      return;
    }

    final boundary = boundaryContext.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      return;
    }

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (data == null) {
      image.dispose();
      return;
    }

    final rgba = data.buffer.asUint8List();
    final x = (localPosition.dx * pixelRatio).round().clamp(0, image.width - 1);
    final y = (localPosition.dy * pixelRatio).round().clamp(
      0,
      image.height - 1,
    );
    final index = (y * image.width + x) * 4;

    if (index + 3 >= rgba.length) {
      image.dispose();
      return;
    }

    final color = Color.fromARGB(
      rgba[index + 3],
      rgba[index],
      rgba[index + 1],
      rgba[index + 2],
    );

    image.dispose();
    drawing.completeColorPick(color);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Picked color: #${color.toARGB32().toRadixString(16).toUpperCase()}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final drawing = context.watch<DrawingProvider>();

    final toolbar = SizedBox(
      width: 220,
      child: DrawingToolbar(
        onExport: () => _exportDrawing(ExportImageFormat.png),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
      extendBodyBehindAppBar: true,
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: Colors.transparent,
              width: 252,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 16,
                    bottom: 16,
                    right: 16,
                  ),
                  child: toolbar,
                ),
              ),
            ),
      body: SafeArea(
        top: isDesktop,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                key: _captureKey,
                child: Stack(
                  children: [
                    const Positioned.fill(child: CanvasWidget()),
                    if (isDesktop)
                      Positioned(left: 16, top: 16, bottom: 16, child: toolbar),
                  ],
                ),
              ),
            ),
            if (drawing.isPickingColor)
              Positioned.fill(
                child: MouseRegion(
                  cursor: SystemMouseCursors.precise,
                  onHover: (event) => context
                      .read<DrawingProvider>()
                      .updatePickerPosition(event.localPosition),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _pickColorAt(details.localPosition),
                    child: ColoredBox(
                      color: Colors.black.withAlpha(20),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 14,
                            top: 14,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Eyedropper: move mouse and click to pick color',
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 14,
                            top: 14,
                            child: FilledButton.tonalIcon(
                              onPressed: () => context
                                  .read<DrawingProvider>()
                                  .cancelColorPick(),
                              icon: const Icon(Icons.close),
                              label: const Text('Cancel'),
                            ),
                          ),
                          if (drawing.pickerPosition != null)
                            Positioned(
                              left: drawing.pickerPosition!.dx - 10,
                              top: drawing.pickerPosition!.dy - 10,
                              child: IgnorePointer(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
