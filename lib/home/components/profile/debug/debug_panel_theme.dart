import 'package:flutter/material.dart';

/// Theme colors for adaptive debug panel UI
class DebugPanelTheme {
  final bool isDark;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color divider;
  final Color icon;
  final Color iconMuted;

  const DebugPanelTheme._({
    required this.isDark,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.divider,
    required this.icon,
    required this.iconMuted,
  });

  factory DebugPanelTheme.dark() => const DebugPanelTheme._(
    isDark: true,
    text: Colors.white,
    textSecondary: Color(0xFFB0B0B0),
    textMuted: Color(0xFF707070),
    surface: Color(0xFF1A1A1F),
    surfaceAlt: Color(0xFF252530),
    border: Color(0xFF3A3A45),
    divider: Color(0xFF2A2A35),
    icon: Color(0xFFD0D0D0),
    iconMuted: Color(0xFF606060),
  );

  factory DebugPanelTheme.light() => const DebugPanelTheme._(
    isDark: false,
    text: Color(0xFF1A1A1F),
    textSecondary: Color(0xFF505050),
    textMuted: Color(0xFF909090),
    surface: Color(0xFFF8F8FA),
    surfaceAlt: Color(0xFFFFFFFF),
    border: Color(0xFFD0D0D5),
    divider: Color(0xFFE5E5EA),
    icon: Color(0xFF404040),
    iconMuted: Color(0xFFA0A0A0),
  );
  
  factory DebugPanelTheme.fromBackground(bool isDarkBackground) {
    return isDarkBackground ? DebugPanelTheme.dark() : DebugPanelTheme.light();
  }
}

/// Color palette data class for color theory presets
class ColorPalette {
  final String name;
  final List<Color> colors;
  final String theory;

  const ColorPalette(this.name, this.colors, this.theory);
}

/// Predefined color palettes based on color theory
const List<ColorPalette> colorPalettes = [
  // === INTENSE SUNSET PALETTE (12-tone derived) ===
  ColorPalette('Sunset Fire', [Color(0xFFFF6A14), Color(0xFFFF541F), Color(0xFFFF442A)], '🌅 Intense orange'),
  ColorPalette('Sunset Blaze', [Color(0xFFFF541F), Color(0xFFFF3533), Color(0xFFFF263D)], '🌅 Orange to red'),
  ColorPalette('Sunset Coral', [Color(0xFFFF442A), Color(0xFFFF263D), Color(0xFFF91A4D)], '🌅 Coral heat'),
  ColorPalette('Sunset Neon', [Color(0xFFFF3533), Color(0xFFF91A4D), Color(0xFFEB125F)], '🌅 Neon poppy'),
  ColorPalette('Sunset Rose', [Color(0xFFF91A4D), Color(0xFFDD0F6F), Color(0xFFC50C82)], '🌅 Electric rose'),
  ColorPalette('Sunset Fuchsia', [Color(0xFFEB125F), Color(0xFFC50C82), Color(0xFFA40A97)], '🌅 Hot fuchsia'),
  ColorPalette('Sunset Violet', [Color(0xFFDD0F6F), Color(0xFFA40A97), Color(0xFF8807A8)], '🌅 Purple wave'),
  ColorPalette('Sunset Glow', [Color(0xFFC50C82), Color(0xFF8807A8), Color(0xFF6A05B9)], '🌅 Afterglow'),
  ColorPalette('Sunset Full', [Color(0xFFFF6A14), Color(0xFFF91A4D), Color(0xFF6A05B9)], '🌅 Full spectrum'),
  ColorPalette('Sunset Warm', [Color(0xFFFF6A14), Color(0xFFFF3533), Color(0xFFEB125F)], '🌅 Warm half'),
  ColorPalette('Sunset Cool', [Color(0xFFDD0F6F), Color(0xFFA40A97), Color(0xFF6A05B9)], '🌅 Cool half'),
  ColorPalette('Sunset Edge', [Color(0xFFFF6A14), Color(0xFFDD0F6F), Color(0xFF6A05B9)], '🌅 Edge colors'),

  // === CLASSIC WARM ===
  ColorPalette('Peach Dream', [Color(0xFFFFD7C0), Color(0xFFFFA573), Color(0xFFFF7BC5)], 'Analogous coral'),
  ColorPalette('Rose Garden', [Color(0xFFFFB8C6), Color(0xFFE88AAB), Color(0xFFD066A0)], 'Analogous pink'),

  // === COOL ===
  ColorPalette('Ocean', [Color(0xFF48CAE4), Color(0xFF0096C7), Color(0xFF0077B6)], 'Analogous blue'),
  ColorPalette('Forest', [Color(0xFF95D5B2), Color(0xFF52B788), Color(0xFF2D6A4F)], 'Analogous green'),
  ColorPalette('Lavender', [Color(0xFFE8D4F0), Color(0xFFC4A8D8), Color(0xFF9B7BB8)], 'Analogous purple'),

  // === COMPLEMENTARY ===
  ColorPalette('Fire & Ice', [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)], 'Complementary'),
  ColorPalette('Royal', [Color(0xFFFFD700), Color(0xFFF8961E), Color(0xFF6A0DAD)], 'Complementary gold'),
  ColorPalette('Coral Sea', [Color(0xFFFF7F50), Color(0xFFFFAA85), Color(0xFF20B2AA)], 'Complementary teal'),

  // === TRIADIC ===
  ColorPalette('Primary', [Color(0xFFFF5252), Color(0xFFFFEB3B), Color(0xFF2196F3)], 'Triadic primary'),
  ColorPalette('Neon', [Color(0xFFFF00FF), Color(0xFF00FFFF), Color(0xFFFFFF00)], 'Triadic neon'),
  ColorPalette('Earth', [Color(0xFFD4A574), Color(0xFF8B9A46), Color(0xFF5D6D7E)], 'Triadic earth'),

  // === SPLIT-COMPLEMENTARY ===
  ColorPalette('Tropical', [Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1)], 'Split-comp'),
  ColorPalette('Berry', [Color(0xFF9B59B6), Color(0xFFE74C3C), Color(0xFF3498DB)], 'Split-comp berry'),

  // === MONOCHROMATIC ===
  ColorPalette('Ember', [Color(0xFFFFF0E6), Color(0xFFFFB380), Color(0xFFCC5500)], 'Mono orange'),
  ColorPalette('Midnight', [Color(0xFFB8C6DB), Color(0xFF63779B), Color(0xFF2C3E50)], 'Mono blue'),
  ColorPalette('Blush', [Color(0xFFFFF0F5), Color(0xFFFFB6C1), Color(0xFFFF69B4)], 'Mono pink'),

  // === SPECIAL ===
  ColorPalette('Aurora', [Color(0xFF00FF87), Color(0xFF60EFFF), Color(0xFFFF00E5)], 'Northern lights'),
  ColorPalette('Candy', [Color(0xFFFF6FD8), Color(0xFF00E4FF), Color(0xFFFFFB7D)], 'Sweet pop'),
  ColorPalette('Cosmos', [Color(0xFFE8D5F2), Color(0xFF9B72CF), Color(0xFF3D1F5C)], 'Deep space'),
];

/// Helper to lighten a color
Color lightenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// Helper to get contrast color for text
Color getContrastColor(Color bgColor) {
  final luminance = (0.299 * bgColor.r + 0.587 * bgColor.g + 0.114 * bgColor.b);
  return luminance > 0.5 ? Colors.black87 : Colors.white;
}











