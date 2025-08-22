import 'package:flutter/material.dart';
import 'list_notes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Notas',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'JetBrains Mono',
        useMaterial3: true,
      ),
      home: const ListNotesScreen(),
    );
  }
}