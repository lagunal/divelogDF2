import 'package:flutter/material.dart';

// Simple theme without Google Fonts for testing
ThemeData get testTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Roboto'),
    bodyMedium: TextStyle(fontFamily: 'Roboto'),
    titleMedium: TextStyle(fontFamily: 'Roboto'),
    headlineMedium: TextStyle(fontFamily: 'Roboto'),
    labelSmall: TextStyle(fontFamily: 'Roboto'),
  ),
);
