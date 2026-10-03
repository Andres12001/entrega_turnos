import 'package:flutter/material.dart';

/// Estilos de la aplicación: simples, con texto grande y buen contraste.
class AppTheme {
  static const Color primario = Color(0xFF3B5BDB);
  static const Color fondo = Color(0xFFF3F5FA);
  static const Color texto = Color(0xFF1B1F33);
  static const Color etiqueta = Color(0xFF2B3157);
  static const Color suave = Color(0xFF6B7280);

  static ThemeData claro() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primario,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: fondo,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        foregroundColor: texto,
        titleTextStyle: TextStyle(
          color: texto,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: Color(0xFF9AA1AE), fontSize: 15),
        border: _borde(const Color(0xFFE2E5EF)),
        enabledBorder: _borde(const Color(0xFFE2E5EF)),
        focusedBorder: _borde(primario, ancho: 1.8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: Color(0xFFC9CEDD)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: texto,
        contentTextStyle: const TextStyle(fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: texto,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFECEEF5),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static OutlineInputBorder _borde(Color color, {double ancho = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: ancho),
      );

  /// Tarjeta blanca con sombra suave.
  static BoxDecoration tarjeta() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B1F33).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      );
}

/// Desplazamiento sin rebote ni estiramiento: las tarjetas se quedan quietas
/// al llegar al final de la lista (Material 3 usa "stretch" por defecto).
class ComportamientoScroll extends MaterialScrollBehavior {
  const ComportamientoScroll();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
