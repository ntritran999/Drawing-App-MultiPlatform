import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:drawing_app/providers/drawing_provider.dart';
import 'package:drawing_app/widgets/toolbar.dart';

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

class DrawingPage extends StatelessWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    const toolbar = SizedBox(
      width: 220,
      child: DrawingToolbar(),
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
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 16),
                  child: toolbar,
                ),
              ),
            ),
      body: SafeArea(
        top: isDesktop,
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(
              child: Center(
                child: Text(
                  'Canvas Placeholder',
                  style: TextStyle(color: Colors.grey, fontSize: 24),
                ),
              ),
            ),
            if (isDesktop)
              Positioned(
                left: 16,
                top: 16,
                bottom: 16,
                child: toolbar,
              ),
          ],
        ),
      ),
    );
  }
}
