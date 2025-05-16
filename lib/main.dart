import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const PokedexApp()); //root widget that deines the app theme
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    //overriding the build method inherited from statelesswidget
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pok-Codex App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        textTheme: const TextTheme(
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
        iconTheme: const IconThemeData(
            color: Colors.cyan), //default color for all icons in the app
      ),
      home: const LoginPage(), //sets the starting screen to loginpage
    );
  }
}
