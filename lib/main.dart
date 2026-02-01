import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SimplePDFReaderApp());
}

class SimplePDFReaderApp extends StatelessWidget {
  const SimplePDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple PDF Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}