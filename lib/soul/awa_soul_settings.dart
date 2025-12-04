import 'package:flutter/material.dart';

/// Global settings for AwaSoul appearance - persists across app session
/// Implements light rendering best practices:
/// - Emissive colors (HDR-like brightness)
/// - Additive blending simulation
/// - Bloom/glow effects
/// - Soft gradient falloff
class AwaSoulSettings extends ChangeNotifier {
  static final AwaSoulSettings _instance = AwaSoulSettings._internal();
  factory AwaSoulSettings() => _instance;
  AwaSoulSettings._internal();
  
  // === 3D PARTICLE SETTINGS ===
  int _particleCount = 350;
  double _particleSize = 3.5;
  
  // === 2D BACKDROP SETTINGS ===
  int _backdropDotCount = 380;
  double _backdropDotSize = 5.0;
  double _backdropOpacity = 0.75;
  
  // === GRADIENT COLORS ===
  Color _gradientStart = const Color(0xFFE8C8B8);  // Center - warm beige
  Color _gradientMid = const Color(0xFFFFD4A8);    // Middle - golden peach
  Color _gradientEnd = const Color(0xFFD8A0A8);    // Edge - dusty rose
  
  // === ANIMATION SPEEDS ===
  double _flickerSpeed = 1.0;
  double _pulseSpeed = 1.0;
  double _driftSpeed = 1.0;
  double _wobbleSpeed = 1.0;
  double _breathingIntensity = 1.0;  // How much the sphere "breathes" (0 = none, 1 = normal, 2 = heavy)
  
  // === LIGHT/EMISSIVE SETTINGS ===
  double _emissiveIntensity = 1.5;    // HDR-like brightness multiplier (1.0 = normal, 2.0+ = glowing)
  double _coreIntensity = 2.0;        // How bright the particle center is
  double _glowRadius = 3.0;           // How far the glow extends (multiplier of particle size)
  double _glowSoftness = 8.0;         // Blur amount for glow layers
  bool _additiveBlending = true;      // Simulate additive blend (lighter colors)
  double _haloOpacity = 0.4;          // Outer halo opacity
  
  // === BLOOM SETTINGS ===
  bool _enableBloom = true;
  double _bloomIntensity = 0.6;
  double _bloomRadius = 12.0;
  double _bloomThreshold = 0.7;       // Only particles brighter than this bloom
  
  // === COLOR TEMPERATURE ===
  double _colorTemperature = 0.5;     // 0 = cool (blue/lavender), 1 = hot (yellow/white)
  double _saturation = 0.8;
  
  // Getters
  int get particleCount => _particleCount;
  double get particleSize => _particleSize;
  int get backdropDotCount => _backdropDotCount;
  double get backdropDotSize => _backdropDotSize;
  double get backdropOpacity => _backdropOpacity;
  Color get gradientStart => _gradientStart;
  Color get gradientMid => _gradientMid;
  Color get gradientEnd => _gradientEnd;
  double get flickerSpeed => _flickerSpeed;
  double get pulseSpeed => _pulseSpeed;
  double get driftSpeed => _driftSpeed;
  double get wobbleSpeed => _wobbleSpeed;
  double get breathingIntensity => _breathingIntensity;
  double get emissiveIntensity => _emissiveIntensity;
  double get coreIntensity => _coreIntensity;
  double get glowRadius => _glowRadius;
  double get glowSoftness => _glowSoftness;
  bool get additiveBlending => _additiveBlending;
  double get haloOpacity => _haloOpacity;
  bool get enableBloom => _enableBloom;
  double get bloomIntensity => _bloomIntensity;
  double get bloomRadius => _bloomRadius;
  double get bloomThreshold => _bloomThreshold;
  double get colorTemperature => _colorTemperature;
  double get saturation => _saturation;
  
  // Setters with notification
  set particleCount(int v) { _particleCount = v; notifyListeners(); }
  set particleSize(double v) { _particleSize = v; notifyListeners(); }
  set backdropDotCount(int v) { _backdropDotCount = v; notifyListeners(); }
  set backdropDotSize(double v) { _backdropDotSize = v; notifyListeners(); }
  set backdropOpacity(double v) { _backdropOpacity = v; notifyListeners(); }
  set gradientStart(Color v) { _gradientStart = v; notifyListeners(); }
  set gradientMid(Color v) { _gradientMid = v; notifyListeners(); }
  set gradientEnd(Color v) { _gradientEnd = v; notifyListeners(); }
  set flickerSpeed(double v) { _flickerSpeed = v; notifyListeners(); }
  set pulseSpeed(double v) { _pulseSpeed = v; notifyListeners(); }
  set driftSpeed(double v) { _driftSpeed = v; notifyListeners(); }
  set wobbleSpeed(double v) { _wobbleSpeed = v; notifyListeners(); }
  set breathingIntensity(double v) { _breathingIntensity = v; notifyListeners(); }
  set emissiveIntensity(double v) { _emissiveIntensity = v; notifyListeners(); }
  set coreIntensity(double v) { _coreIntensity = v; notifyListeners(); }
  set glowRadius(double v) { _glowRadius = v; notifyListeners(); }
  set glowSoftness(double v) { _glowSoftness = v; notifyListeners(); }
  set additiveBlending(bool v) { _additiveBlending = v; notifyListeners(); }
  set haloOpacity(double v) { _haloOpacity = v; notifyListeners(); }
  set enableBloom(bool v) { _enableBloom = v; notifyListeners(); }
  set bloomIntensity(double v) { _bloomIntensity = v; notifyListeners(); }
  set bloomRadius(double v) { _bloomRadius = v; notifyListeners(); }
  set bloomThreshold(double v) { _bloomThreshold = v; notifyListeners(); }
  set colorTemperature(double v) { _colorTemperature = v; notifyListeners(); }
  set saturation(double v) { _saturation = v; notifyListeners(); }
  
  /// Get emissive color based on temperature (for particles)
  /// Hot = yellow/white, Cool = pink/lavender
  Color getEmissiveColor(double baseHue) {
    if (_colorTemperature > 0.7) {
      // Hot: yellow to white
      return Color.lerp(
        const Color(0xFFFFE4B5), // Warm yellow
        const Color(0xFFFFFAF0), // Almost white
        (_colorTemperature - 0.7) / 0.3,
      )!;
    } else if (_colorTemperature > 0.4) {
      // Warm: orange to yellow
      return Color.lerp(
        const Color(0xFFFFB07C), // Orange
        const Color(0xFFFFE4B5), // Warm yellow
        (_colorTemperature - 0.4) / 0.3,
      )!;
    } else {
      // Cool: pink/lavender to orange
      return Color.lerp(
        const Color(0xFFD8A0C8), // Lavender pink
        const Color(0xFFFFB07C), // Orange
        _colorTemperature / 0.4,
      )!;
    }
  }
  
  /// Apply additive-like color boost (simulates additive blending)
  Color applyAdditiveBoost(Color color, double intensity) {
    if (!_additiveBlending) return color;
    
    // Lighten the color to simulate additive blending
    final r = (color.red + (255 - color.red) * intensity * 0.3).clamp(0, 255).toInt();
    final g = (color.green + (255 - color.green) * intensity * 0.3).clamp(0, 255).toInt();
    final b = (color.blue + (255 - color.blue) * intensity * 0.3).clamp(0, 255).toInt();
    return Color.fromARGB(color.alpha, r, g, b);
  }
  
  /// Reset to defaults
  void resetToDefaults() {
    _particleCount = 350;
    _particleSize = 3.5;
    _backdropDotCount = 380;
    _backdropDotSize = 5.0;
    _backdropOpacity = 0.75;
    _gradientStart = const Color(0xFFE8C8B8);
    _gradientMid = const Color(0xFFFFD4A8);
    _gradientEnd = const Color(0xFFD8A0A8);
    _flickerSpeed = 1.0;
    _pulseSpeed = 1.0;
    _driftSpeed = 1.0;
    _wobbleSpeed = 1.0;
    _breathingIntensity = 1.0;
    _emissiveIntensity = 1.5;
    _coreIntensity = 2.0;
    _glowRadius = 3.0;
    _glowSoftness = 8.0;
    _additiveBlending = true;
    _haloOpacity = 0.4;
    _enableBloom = true;
    _bloomIntensity = 0.6;
    _bloomRadius = 12.0;
    _bloomThreshold = 0.7;
    _colorTemperature = 0.5;
    _saturation = 0.8;
    notifyListeners();
  }
}

