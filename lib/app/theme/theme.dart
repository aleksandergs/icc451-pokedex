import 'package:flutter/material.dart';

class TypeColors {
  const TypeColors._();

  static const Map<String, Color> _colors = <String, Color>{
    'normal': Color(0xFF9FA19F),
    'fire': Color(0xFFE62829),
    'water': Color(0xFF2980EF),
    'electric': Color(0xFFFAC000),
    'grass': Color(0xFF3FA129),
    'ice': Color(0xFF3FD8FF),
    'fighting': Color(0xFFFF8000),
    'poison': Color(0xFF9141CB),
    'ground': Color(0xFF915121),
    'flying': Color(0xFF81B9EF),
    'psychic': Color(0xFFEF4179),
    'bug': Color(0xFF91A119),
    'rock': Color(0xFFAFA981),
    'ghost': Color(0xFF704170),
    'dragon': Color(0xFF5060E1),
    'dark': Color(0xFF624D4E),
    'steel': Color(0xFF60A1B8),
    'fairy': Color(0xFFEF70EF),
    'stellar': Color(0xFF40B5A5),
    'unknown': Color(0xFF68A090),
  };

  static const Map<String, String> _labels = <String, String>{
    'normal': 'Normal',
    'fire': 'Fuego',
    'water': 'Agua',
    'electric': 'Eléctrico',
    'grass': 'Planta',
    'ice': 'Hielo',
    'fighting': 'Lucha',
    'poison': 'Veneno',
    'ground': 'Tierra',
    'flying': 'Volador',
    'psychic': 'Psíquico',
    'bug': 'Bicho',
    'rock': 'Roca',
    'ghost': 'Fantasma',
    'dragon': 'Dragón',
    'dark': 'Siniestro',
    'steel': 'Acero',
    'fairy': 'Hada',
    'stellar': 'Estelar',
    'unknown': 'Desconocido',
  };

  static Color of(String type) =>
      _colors[type.toLowerCase()] ?? const Color(0xFF757575);

  static Color onColor(String type) {
    final Color background = of(type);
    return background.computeLuminance() > 0.5
        ? const Color(0xFF1A1A1A)
        : Colors.white;
  }

  static String label(String type) => _labels[type.toLowerCase()] ?? type;
}

/// Material 3
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFFD92B3A);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
