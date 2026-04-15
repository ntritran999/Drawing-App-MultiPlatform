import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Draw',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DrawingPage(),
    );
  }
}

class DrawingPage extends StatelessWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final toolbar = Container(
      width: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Toolbar\nPlaceholder',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
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
              width: 132,
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
