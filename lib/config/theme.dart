import 'package:flutter/material.dart';

// =================================================================
// PALETA DE COLORES EVCONNECT
// =================================================================

// Colores principales
const Color kPrimaryColor = Color(0xFF37A686); // Verde medio (principal)
const Color kPrimaryDark = Color(0xFF2C403A); // Verde oscuro (fondo)
const Color kPrimaryLight = Color(0xFF52F2B8); // Verde claro (acentos)
const Color kBackgroundColor = Color(0xFFF2F2F2); // Blanco/Gris claro (fondos de tarjeta/cards)
const Color kTextDark = Color(0xFF0D0D0D); // Negro (texto dentro de tarjetas)
const Color kWhite = Color(0xFFFFFFFF); // Blanco (texto en fondo oscuro)

// Estilo de texto para títulos grandes
const TextStyle kTitleStyle = TextStyle(
  fontSize: 32.0,
  fontWeight: FontWeight.bold,
  color: kWhite,
);

// Estilo de texto para subtítulos o prompts
const TextStyle kSubtitleStyle = TextStyle(
  fontSize: 14.0,
  color: kWhite,
  fontWeight: FontWeight.w400,
);

// =================================================================
// DECORACIONES DE WIDGETS
// =================================================================

// Decoración de sombra para las tarjetas de input (basada en PrimaryDark)
const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x1A2C403A), // 10% opacidad de kPrimaryDark
    blurRadius: 10,
    offset: Offset(0, 4),
  ),
];

// Estilo de botón principal
ButtonStyle kPrimaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: kPrimaryColor,
  minimumSize: const Size(double.infinity, 55),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
  elevation: 5,
);

// Estilo de texto para botón principal
const TextStyle kPrimaryButtonTextStyle = TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
  color: kWhite,
);

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimaryDark,
      elevation: 0,
      iconTheme: IconThemeData(color: kWhite),
      titleTextStyle: TextStyle(
        color: kWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: kPrimaryButtonStyle,
    ),
    textTheme: const TextTheme(
      headlineLarge: kTitleStyle,
      titleMedium: kSubtitleStyle,
    ),
  );
}