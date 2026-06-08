import 'package:flutter/material.dart';

const kPurple = Color(0xFF534AB7);
const kPurpleLight = Color(0xFFEEEDFE);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPurple,
    primary: kPurple,
  ),
  fontFamily: 'SF Pro Display',
  scaffoldBackgroundColor: const Color(0xFFF5F5F7),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1C1C1E),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontFamily: 'SF Pro Display',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1C1C1E),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
    ),
    margin: const EdgeInsets.only(bottom: 8),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: kPurple,
    unselectedItemColor: Color(0xFF8E8E93),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F5F7),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPurple,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),
);

const List<Color> kCouleursMatiere = [
  Color(0xFF534AB7),
  Color(0xFF1D9E75),
  Color(0xFFEF9F27),
  Color(0xFFD4537E),
  Color(0xFF378ADD),
  Color(0xFF639922),
  Color(0xFFD85A30),
  Color(0xFF888780),
];

String formatDuree(double heures) {
  final h = heures.floor();
  final m = ((heures - h) * 60).round();
  if (m == 0) return '${h}h';
  return '${h}h${m.toString().padLeft(2, '0')}';
}

String formatHeure(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
