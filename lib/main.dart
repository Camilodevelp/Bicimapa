import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // ojo: revisa que el archivo se llame bien

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bicimapa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // 👈 aquí llamamos tu pantalla principal
    );
  }
}
