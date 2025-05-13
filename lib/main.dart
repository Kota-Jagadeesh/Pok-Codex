// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(
      const PokedexApp()); // creates instance of pokedex widget and passes to runApp
}

class PokedexApp extends StatelessWidget {
  // the ui is fixed not updated dynamically
  const PokedexApp({super.key}); // initialisess the pokedex widget

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pok-Codex App',
      theme: ThemeData(
        // class that definess app's visual styling
        brightness: Brightness.dark,
        primarySwatch:
            Colors.cyan, // used for appbars, buttons and other elements
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        textTheme: const TextTheme(
          // defines styles for diff text types
          headlineMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyan),
      ),
      home: const HomePage(),
    );
  }
}
