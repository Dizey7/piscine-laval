import 'package:flutter/material.dart';

/// Couleurs officielles MTL Live — thème Montréal
class MtlColors {
  MtlColors._();

  // Couleurs primaires Montréal
  static const Color bleuMtl = Color(0xFF003399);
  static const Color orangeMtl = Color(0xFFFF6600);
  static const Color blanc = Color(0xFFFFFFFF);

  // Dark mode palette
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkCardAlt = Color(0xFF1E2A47);

  // Light mode palette
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Statuts
  static const Color disponible = Color(0xFF00C853);
  static const Color presqueComplet = Color(0xFFFF9800);
  static const Color complet = Color(0xFFD32F2F);
  static const Color annule = Color(0xFFB71C1C);
  static const Color gratuit = Color(0xFF00E676);

  // Texte
  static const Color darkText = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);

  // Sources badges
  static const Color ticketmaster = Color(0xFF026CDF);
  static const Color villeMtl = Color(0xFF1B8A2C);
  static const Color predictHQ = Color(0xFF6C5CE7);
}

class MtlTheme {
  MtlTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Montserrat',
        colorScheme: const ColorScheme.dark(
          primary: MtlColors.bleuMtl,
          secondary: MtlColors.orangeMtl,
          surface: MtlColors.darkSurface,
          error: MtlColors.annule,
          onPrimary: MtlColors.blanc,
          onSecondary: MtlColors.blanc,
          onSurface: MtlColors.darkText,
        ),
        scaffoldBackgroundColor: MtlColors.darkBg,
        cardTheme: CardTheme(
          color: MtlColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: MtlColors.darkBg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: MtlColors.blanc,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: MtlColors.darkSurface,
          selectedItemColor: MtlColors.orangeMtl,
          unselectedItemColor: MtlColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: MtlColors.darkCardAlt,
          selectedColor: MtlColors.bleuMtl,
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            color: MtlColors.darkText,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: MtlColors.blanc,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: MtlColors.blanc,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MtlColors.blanc,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MtlColors.blanc,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MtlColors.darkText,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            color: MtlColors.darkText,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            color: MtlColors.darkTextSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MtlColors.blanc,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MtlColors.orangeMtl,
            foregroundColor: MtlColors.blanc,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: MtlColors.darkCardAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: const TextStyle(
            color: MtlColors.darkTextSecondary,
          ),
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Montserrat',
        colorScheme: const ColorScheme.light(
          primary: MtlColors.bleuMtl,
          secondary: MtlColors.orangeMtl,
          surface: MtlColors.lightSurface,
          error: MtlColors.annule,
          onPrimary: MtlColors.blanc,
          onSecondary: MtlColors.blanc,
          onSurface: MtlColors.lightText,
        ),
        scaffoldBackgroundColor: MtlColors.lightBg,
        cardTheme: CardTheme(
          color: MtlColors.lightCard,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: MtlColors.lightBg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: MtlColors.lightText,
          ),
          iconTheme: IconThemeData(color: MtlColors.lightText),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: MtlColors.lightSurface,
          selectedItemColor: MtlColors.orangeMtl,
          unselectedItemColor: MtlColors.lightTextSecondary,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      );
}
