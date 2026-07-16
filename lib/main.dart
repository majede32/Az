import 'package:flutter/material.dart';
import 'features/library/home_screen.dart';

void main() {
  runApp(const MangaComboApp());
}

class MangaComboApp extends StatelessWidget {
  const MangaComboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Combo',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
