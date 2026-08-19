import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const UnitFlowApp());
}

class UnitFlowApp extends StatelessWidget {
  const UnitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3657C8),
      brightness: Brightness.light,
    );
    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9EB0FF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'UnitFlow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
