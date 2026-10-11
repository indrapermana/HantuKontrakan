import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7357B7),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF100E26),
    useMaterial3: true,
  );
}
