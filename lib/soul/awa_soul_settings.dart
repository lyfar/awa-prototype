import 'package:flutter/material.dart';

/// Motion pattern types for particle/dot animations
enum MotionPattern {
  gentle,      // Soft sine wave drift
  organic,     // Perlin-like noise movement
  pulsing,     // Rhythmic expansion/contraction
  swirl,       // Circular/spiral drift
  jitter,      // Quick random micro-movements
  breathe,     // Slow inhale/exhale rhythm
  float,       // Lazy upward float tendency
}

/// Wiggle style for shape deformation
enum WiggleStyle {
  none,        // No wiggle
  subtle,      // Minimal organic wobble
  fluid,       // Smooth liquid-like deformation
  electric,    // Quick nervous energy
  wave,        // Wave propagation through particles
  heartbeat,   // Pulse-like expansion
}

/// Flicker behavior for brightness changes
enum FlickerMode {
  off,         // Steady brightness
  gentle,      // Soft twinkle
  candle,      // Fire-like flicker
  sparkle,     // Sharp random flashes
  sync,        // All particles flicker together
  wave,        // Brightness wave across sphere
}

/// 3D Particle Layer Settings
class Layer3DSettings {
  // === VISIBILITY ===
  bool enabled;
  
  // === SIZE ===
  int particleCount;
  double particleSize;
  double sizeVariation;      // 0-1: how much sizes differ
  double depthScaling;       // How much depth affects size
  
  // === LIGHT / EMISSIVE ===
  double emissiveIntensity;  // HDR brightness multiplier
  double coreIntensity;      // Center brightness
  double glowRadius;         // Glow spread
  double glowSoftness;       // Blur amount
  double haloOpacity;        // Outer glow visibility
  bool additiveBlending;     // Simulate light addition
  
  // === COLOR (Core=brightest white center, Mid=transition, Outer=edge) ===
  Color coreColor;           // Hot white center (brightest)
  Color midColor;            // Transition color
  Color outerColor;          // Edge color (warmest)
  double colorTemperature;   // 0=cool, 1=hot
  double saturation;
  
  // === MOTION ===
  MotionPattern motionPattern;
  double driftSpeed;         // Overall movement speed
  double driftIntensity;     // How far particles drift
  
  // === WIGGLE ===
  WiggleStyle wiggleStyle;
  double wiggleSpeed;
  double wiggleIntensity;
  
  // === FLICKER ===
  FlickerMode flickerMode;
  double flickerSpeed;
  double flickerIntensity;
  
  // === PULSE ===
  double pulseSpeed;         // Brightness rhythm
  double pulseIntensity;
  bool syncPulse;            // All particles pulse together
  
  // === BLOOM ===
  bool enableBloom;
  double bloomIntensity;
  double bloomRadius;
  
  Layer3DSettings({
    this.enabled = true,
    this.particleCount = 470,
    this.particleSize = 4.85,
    this.sizeVariation = 0.5,
    this.depthScaling = 0.4,
    this.emissiveIntensity = 3.0,
    this.coreIntensity = 4.0,
    this.glowRadius = 1.0,
    this.glowSoftness = 20.0,
    this.haloOpacity = 0.4,
    this.additiveBlending = true,
    this.coreColor = const Color(0xFFFFFFFB),  // Near white - brightest
    this.midColor = const Color(0xFFFFE8C0),   // Warm yellow
    this.outerColor = const Color(0xFFFFB880), // Warm orange
    this.colorTemperature = 0.5,
    this.saturation = 0.8,
    this.motionPattern = MotionPattern.gentle,
    this.driftSpeed = 1.0,
    this.driftIntensity = 1.5,
    this.wiggleStyle = WiggleStyle.subtle,
    this.wiggleSpeed = 1.0,
    this.wiggleIntensity = 0.12,
    this.flickerMode = FlickerMode.gentle,
    this.flickerSpeed = 2.6,
    this.flickerIntensity = 0.15,
    this.pulseSpeed = 2.98,
    this.pulseIntensity = 0.1,
    this.syncPulse = false,
    this.enableBloom = true,
    this.bloomIntensity = 0.6,
    this.bloomRadius = 12.0,
  });
  
  Layer3DSettings copyWith({
    bool? enabled,
    int? particleCount,
    double? particleSize,
    double? sizeVariation,
    double? depthScaling,
    double? emissiveIntensity,
    double? coreIntensity,
    double? glowRadius,
    double? glowSoftness,
    double? haloOpacity,
    bool? additiveBlending,
    Color? coreColor,
    Color? midColor,
    Color? outerColor,
    double? colorTemperature,
    double? saturation,
    MotionPattern? motionPattern,
    double? driftSpeed,
    double? driftIntensity,
    WiggleStyle? wiggleStyle,
    double? wiggleSpeed,
    double? wiggleIntensity,
    FlickerMode? flickerMode,
    double? flickerSpeed,
    double? flickerIntensity,
    double? pulseSpeed,
    double? pulseIntensity,
    bool? syncPulse,
    bool? enableBloom,
    double? bloomIntensity,
    double? bloomRadius,
  }) {
    return Layer3DSettings(
      enabled: enabled ?? this.enabled,
      particleCount: particleCount ?? this.particleCount,
      particleSize: particleSize ?? this.particleSize,
      sizeVariation: sizeVariation ?? this.sizeVariation,
      depthScaling: depthScaling ?? this.depthScaling,
      emissiveIntensity: emissiveIntensity ?? this.emissiveIntensity,
      coreIntensity: coreIntensity ?? this.coreIntensity,
      glowRadius: glowRadius ?? this.glowRadius,
      glowSoftness: glowSoftness ?? this.glowSoftness,
      haloOpacity: haloOpacity ?? this.haloOpacity,
      additiveBlending: additiveBlending ?? this.additiveBlending,
      coreColor: coreColor ?? this.coreColor,
      midColor: midColor ?? this.midColor,
      outerColor: outerColor ?? this.outerColor,
      colorTemperature: colorTemperature ?? this.colorTemperature,
      saturation: saturation ?? this.saturation,
      motionPattern: motionPattern ?? this.motionPattern,
      driftSpeed: driftSpeed ?? this.driftSpeed,
      driftIntensity: driftIntensity ?? this.driftIntensity,
      wiggleStyle: wiggleStyle ?? this.wiggleStyle,
      wiggleSpeed: wiggleSpeed ?? this.wiggleSpeed,
      wiggleIntensity: wiggleIntensity ?? this.wiggleIntensity,
      flickerMode: flickerMode ?? this.flickerMode,
      flickerSpeed: flickerSpeed ?? this.flickerSpeed,
      flickerIntensity: flickerIntensity ?? this.flickerIntensity,
      pulseSpeed: pulseSpeed ?? this.pulseSpeed,
      pulseIntensity: pulseIntensity ?? this.pulseIntensity,
      syncPulse: syncPulse ?? this.syncPulse,
      enableBloom: enableBloom ?? this.enableBloom,
      bloomIntensity: bloomIntensity ?? this.bloomIntensity,
      bloomRadius: bloomRadius ?? this.bloomRadius,
    );
  }
}

/// 2D Backdrop Layer Settings
class Layer2DSettings {
  // === VISIBILITY ===
  bool enabled;
  
  // === SIZE ===
  int dotCount;
  double dotSize;
  double sizeVariation;       // Size difference across dots
  double centerScale;         // Dots bigger/smaller in center
  double edgeFade;            // How much dots fade at edges
  
  // === OPACITY ===
  double opacity;
  double centerOpacity;       // Opacity boost in center
  
  // === LIGHT / GLOW ===
  double glowIntensity;       // Soft glow around dots
  double glowSize;            // Glow spread multiplier
  double innerGlow;           // Secondary glow layer
  
  // === GRADIENT COLORS ===
  Color gradientStart;        // Center color
  Color gradientMid;          // Middle color
  Color gradientEnd;          // Edge color
  
  // === MOTION ===
  MotionPattern motionPattern;
  double driftSpeed;
  double driftIntensity;
  double rotationSpeed;       // Spiral rotation
  
  // === PULSE / BLINK ===
  FlickerMode blinkMode;
  double blinkSpeed;
  double blinkIntensity;
  bool syncBlink;             // All dots blink together
  
  // === SPIRAL PATTERN ===
  double spiralTightness;     // How tight the spiral is
  double spiralExpansion;     // Breathing expansion of spiral
  
  Layer2DSettings({
    this.enabled = true,
    this.dotCount = 152,
    this.dotSize = 4.35,
    this.sizeVariation = 0.3,
    this.centerScale = 0.8,
    this.edgeFade = 0.9,
    this.opacity = 0.56,
    this.centerOpacity = 0.3,
    this.glowIntensity = 0.5,
    this.glowSize = 2.0,
    this.innerGlow = 0.6,
    this.gradientStart = const Color(0xFFFFA573),
    this.gradientMid = const Color(0xFFFF8B7A),
    this.gradientEnd = const Color(0xFFFF7BC5),
    this.motionPattern = MotionPattern.gentle,
    this.driftSpeed = 0.3,
    this.driftIntensity = 0.5,
    this.rotationSpeed = 0.0,
    this.blinkMode = FlickerMode.gentle,
    this.blinkSpeed = 0.6,
    this.blinkIntensity = 0.25,
    this.syncBlink = false,
    this.spiralTightness = 1.0,
    this.spiralExpansion = 0.0,
  });
  
  Layer2DSettings copyWith({
    bool? enabled,
    int? dotCount,
    double? dotSize,
    double? sizeVariation,
    double? centerScale,
    double? edgeFade,
    double? opacity,
    double? centerOpacity,
    double? glowIntensity,
    double? glowSize,
    double? innerGlow,
    Color? gradientStart,
    Color? gradientMid,
    Color? gradientEnd,
    MotionPattern? motionPattern,
    double? driftSpeed,
    double? driftIntensity,
    double? rotationSpeed,
    FlickerMode? blinkMode,
    double? blinkSpeed,
    double? blinkIntensity,
    bool? syncBlink,
    double? spiralTightness,
    double? spiralExpansion,
  }) {
    return Layer2DSettings(
      enabled: enabled ?? this.enabled,
      dotCount: dotCount ?? this.dotCount,
      dotSize: dotSize ?? this.dotSize,
      sizeVariation: sizeVariation ?? this.sizeVariation,
      centerScale: centerScale ?? this.centerScale,
      edgeFade: edgeFade ?? this.edgeFade,
      opacity: opacity ?? this.opacity,
      centerOpacity: centerOpacity ?? this.centerOpacity,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      glowSize: glowSize ?? this.glowSize,
      innerGlow: innerGlow ?? this.innerGlow,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMid: gradientMid ?? this.gradientMid,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      motionPattern: motionPattern ?? this.motionPattern,
      driftSpeed: driftSpeed ?? this.driftSpeed,
      driftIntensity: driftIntensity ?? this.driftIntensity,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
      blinkMode: blinkMode ?? this.blinkMode,
      blinkSpeed: blinkSpeed ?? this.blinkSpeed,
      blinkIntensity: blinkIntensity ?? this.blinkIntensity,
      syncBlink: syncBlink ?? this.syncBlink,
      spiralTightness: spiralTightness ?? this.spiralTightness,
      spiralExpansion: spiralExpansion ?? this.spiralExpansion,
    );
  }
}

/// Background preset types
enum BackgroundPreset {
  black,
  white,
  midnight,      // Deep blue-black
  warmDark,      // Warm dark brown
  coolGray,      // Cool gray
  forest,        // Deep forest green
  wine,          // Deep wine red
  ocean,         // Deep ocean blue
  custom,        // User-defined color
}

/// Global sphere breathing/scale settings
class SphereSettings {
  double breathingSpeed;
  double breathingIntensity;
  double baseScale;
  
  // Background settings
  BackgroundPreset backgroundPreset;
  Color customBackgroundColor;
  
  SphereSettings({
    this.breathingSpeed = 0.35,
    this.breathingIntensity = 1.88,
    this.baseScale = 1.0,
    this.backgroundPreset = BackgroundPreset.black,
    this.customBackgroundColor = const Color(0xFF1A1A1F),
  });
  
  /// Get the actual background color based on preset
  Color get backgroundColor {
    switch (backgroundPreset) {
      case BackgroundPreset.black:
        return const Color(0xFF000000);
      case BackgroundPreset.white:
        return const Color(0xFFFFFFFF);
      case BackgroundPreset.midnight:
        return const Color(0xFF0D1117);
      case BackgroundPreset.warmDark:
        return const Color(0xFF1A1410);
      case BackgroundPreset.coolGray:
        return const Color(0xFF1C1C1E);
      case BackgroundPreset.forest:
        return const Color(0xFF0D1A14);
      case BackgroundPreset.wine:
        return const Color(0xFF1A0D12);
      case BackgroundPreset.ocean:
        return const Color(0xFF0A1520);
      case BackgroundPreset.custom:
        return customBackgroundColor;
    }
  }
  
  /// Whether the background is dark (for UI theming)
  bool get isDarkBackground {
    final color = backgroundColor;
    final luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
    return luminance < 0.5;
  }
  
  SphereSettings copyWith({
    double? breathingSpeed,
    double? breathingIntensity,
    double? baseScale,
    BackgroundPreset? backgroundPreset,
    Color? customBackgroundColor,
  }) {
    return SphereSettings(
      breathingSpeed: breathingSpeed ?? this.breathingSpeed,
      breathingIntensity: breathingIntensity ?? this.breathingIntensity,
      baseScale: baseScale ?? this.baseScale,
      backgroundPreset: backgroundPreset ?? this.backgroundPreset,
      customBackgroundColor: customBackgroundColor ?? this.customBackgroundColor,
    );
  }
}

/// Global settings for AwaSoul appearance - persists across app session
/// Now organized by layer (3D particles, 2D backdrop) with comprehensive controls
class AwaSoulSettings extends ChangeNotifier {
  static final AwaSoulSettings _instance = AwaSoulSettings._internal();
  factory AwaSoulSettings() => _instance;
  AwaSoulSettings._internal();
  
  // === LAYER SETTINGS ===
  Layer3DSettings _layer3D = Layer3DSettings();
  Layer2DSettings _layer2D = Layer2DSettings();
  SphereSettings _sphere = SphereSettings();
  
  // === GETTERS ===
  Layer3DSettings get layer3D => _layer3D;
  Layer2DSettings get layer2D => _layer2D;
  SphereSettings get sphere => _sphere;
  
  // === LAYER SETTERS ===
  set layer3D(Layer3DSettings v) { _layer3D = v; notifyListeners(); }
  set layer2D(Layer2DSettings v) { _layer2D = v; notifyListeners(); }
  set sphere(SphereSettings v) { _sphere = v; notifyListeners(); }
  
  /// Update 3D layer with new values
  void update3D(Layer3DSettings Function(Layer3DSettings) updater) {
    _layer3D = updater(_layer3D);
    notifyListeners();
  }
  
  /// Update 2D layer with new values  
  void update2D(Layer2DSettings Function(Layer2DSettings) updater) {
    _layer2D = updater(_layer2D);
    notifyListeners();
  }
  
  /// Update sphere settings
  void updateSphere(SphereSettings Function(SphereSettings) updater) {
    _sphere = updater(_sphere);
    notifyListeners();
  }
  
  // === LEGACY GETTERS (for backward compatibility) ===
  int get particleCount => _layer3D.particleCount;
  double get particleSize => _layer3D.particleSize;
  int get backdropDotCount => _layer2D.dotCount;
  double get backdropDotSize => _layer2D.dotSize;
  double get backdropOpacity => _layer2D.opacity;
  Color get gradientStart => _layer2D.gradientStart;
  Color get gradientMid => _layer2D.gradientMid;
  Color get gradientEnd => _layer2D.gradientEnd;
  double get flickerSpeed => _layer3D.flickerSpeed;
  double get pulseSpeed => _layer3D.pulseSpeed;
  double get driftSpeed => _layer3D.driftSpeed;
  double get wobbleSpeed => _layer3D.wiggleSpeed;
  double get breathingIntensity => _sphere.breathingIntensity;
  bool get showParticles => _layer3D.enabled;
  bool get showBackdrop => _layer2D.enabled;
  double get emissiveIntensity => _layer3D.emissiveIntensity;
  double get coreIntensity => _layer3D.coreIntensity;
  double get glowRadius => _layer3D.glowRadius;
  double get glowSoftness => _layer3D.glowSoftness;
  bool get additiveBlending => _layer3D.additiveBlending;
  double get haloOpacity => _layer3D.haloOpacity;
  bool get enableBloom => _layer3D.enableBloom;
  double get bloomIntensity => _layer3D.bloomIntensity;
  double get bloomRadius => _layer3D.bloomRadius;
  double get bloomThreshold => 0.7;
  double get colorTemperature => _layer3D.colorTemperature;
  double get saturation => _layer3D.saturation;
  
  // === LEGACY SETTERS (for backward compatibility) ===
  set particleCount(int v) { _layer3D.particleCount = v; notifyListeners(); }
  set particleSize(double v) { _layer3D.particleSize = v; notifyListeners(); }
  set backdropDotCount(int v) { _layer2D.dotCount = v; notifyListeners(); }
  set backdropDotSize(double v) { _layer2D.dotSize = v; notifyListeners(); }
  set backdropOpacity(double v) { _layer2D.opacity = v; notifyListeners(); }
  set gradientStart(Color v) { _layer2D.gradientStart = v; notifyListeners(); }
  set gradientMid(Color v) { _layer2D.gradientMid = v; notifyListeners(); }
  set gradientEnd(Color v) { _layer2D.gradientEnd = v; notifyListeners(); }
  set flickerSpeed(double v) { _layer3D.flickerSpeed = v; notifyListeners(); }
  set pulseSpeed(double v) { _layer3D.pulseSpeed = v; notifyListeners(); }
  set driftSpeed(double v) { _layer3D.driftSpeed = v; notifyListeners(); }
  set wobbleSpeed(double v) { _layer3D.wiggleSpeed = v; notifyListeners(); }
  set breathingIntensity(double v) { _sphere.breathingIntensity = v; notifyListeners(); }
  set showParticles(bool v) { _layer3D.enabled = v; notifyListeners(); }
  set showBackdrop(bool v) { _layer2D.enabled = v; notifyListeners(); }
  set emissiveIntensity(double v) { _layer3D.emissiveIntensity = v; notifyListeners(); }
  set coreIntensity(double v) { _layer3D.coreIntensity = v; notifyListeners(); }
  set glowRadius(double v) { _layer3D.glowRadius = v; notifyListeners(); }
  set glowSoftness(double v) { _layer3D.glowSoftness = v; notifyListeners(); }
  set additiveBlending(bool v) { _layer3D.additiveBlending = v; notifyListeners(); }
  set haloOpacity(double v) { _layer3D.haloOpacity = v; notifyListeners(); }
  set enableBloom(bool v) { _layer3D.enableBloom = v; notifyListeners(); }
  set bloomIntensity(double v) { _layer3D.bloomIntensity = v; notifyListeners(); }
  set bloomRadius(double v) { _layer3D.bloomRadius = v; notifyListeners(); }
  set colorTemperature(double v) { _layer3D.colorTemperature = v; notifyListeners(); }
  set saturation(double v) { _layer3D.saturation = v; notifyListeners(); }
  
  /// Get emissive color based on temperature (for particles)
  Color getEmissiveColor(double baseHue) {
    final temp = _layer3D.colorTemperature;
    if (temp > 0.7) {
      return Color.lerp(
        const Color(0xFFFFE4B5),
        const Color(0xFFFFFAF0),
        (temp - 0.7) / 0.3,
      )!;
    } else if (temp > 0.4) {
      return Color.lerp(
        const Color(0xFFFFB07C),
        const Color(0xFFFFE4B5),
        (temp - 0.4) / 0.3,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFD8A0C8),
        const Color(0xFFFFB07C),
        temp / 0.4,
      )!;
    }
  }
  
  /// Apply additive-like color boost (simulates additive blending)
  Color applyAdditiveBoost(Color color, double intensity) {
    if (!_layer3D.additiveBlending) return color;
    
    final r = (color.red + (255 - color.red) * intensity * 0.3).clamp(0, 255).toInt();
    final g = (color.green + (255 - color.green) * intensity * 0.3).clamp(0, 255).toInt();
    final b = (color.blue + (255 - color.blue) * intensity * 0.3).clamp(0, 255).toInt();
    return Color.fromARGB(color.alpha, r, g, b);
  }
  
  /// Reset to defaults
  void resetToDefaults() {
    _layer3D = Layer3DSettings();
    _layer2D = Layer2DSettings();
    _sphere = SphereSettings();
    notifyListeners();
  }
  
  /// Reset only 3D layer
  void reset3D() {
    _layer3D = Layer3DSettings();
    notifyListeners();
  }
  
  /// Reset only 2D layer
  void reset2D() {
    _layer2D = Layer2DSettings();
    notifyListeners();
  }
  
  /// Export settings as formatted string
  String exportSettings() {
    return '''
AwaSoul Settings Export
=======================
// 3D PARTICLES
enabled: ${_layer3D.enabled}
particleCount: ${_layer3D.particleCount}
particleSize: ${_layer3D.particleSize.toStringAsFixed(2)}
sizeVariation: ${_layer3D.sizeVariation.toStringAsFixed(2)}
emissiveIntensity: ${_layer3D.emissiveIntensity.toStringAsFixed(2)}
coreIntensity: ${_layer3D.coreIntensity.toStringAsFixed(2)}
glowRadius: ${_layer3D.glowRadius.toStringAsFixed(2)}
glowSoftness: ${_layer3D.glowSoftness.toStringAsFixed(2)}
haloOpacity: ${_layer3D.haloOpacity.toStringAsFixed(2)}
motionPattern: ${_layer3D.motionPattern.name}
driftSpeed: ${_layer3D.driftSpeed.toStringAsFixed(2)}
wiggleStyle: ${_layer3D.wiggleStyle.name}
wiggleSpeed: ${_layer3D.wiggleSpeed.toStringAsFixed(2)}
flickerMode: ${_layer3D.flickerMode.name}
flickerSpeed: ${_layer3D.flickerSpeed.toStringAsFixed(2)}
pulseSpeed: ${_layer3D.pulseSpeed.toStringAsFixed(2)}
enableBloom: ${_layer3D.enableBloom}
bloomIntensity: ${_layer3D.bloomIntensity.toStringAsFixed(2)}

// 2D BACKDROP
enabled: ${_layer2D.enabled}
dotCount: ${_layer2D.dotCount}
dotSize: ${_layer2D.dotSize.toStringAsFixed(2)}
opacity: ${_layer2D.opacity.toStringAsFixed(2)}
glowIntensity: ${_layer2D.glowIntensity.toStringAsFixed(2)}
gradientStart: 0x${_layer2D.gradientStart.value.toRadixString(16).toUpperCase()}
gradientMid: 0x${_layer2D.gradientMid.value.toRadixString(16).toUpperCase()}
gradientEnd: 0x${_layer2D.gradientEnd.value.toRadixString(16).toUpperCase()}
motionPattern: ${_layer2D.motionPattern.name}
blinkMode: ${_layer2D.blinkMode.name}
blinkSpeed: ${_layer2D.blinkSpeed.toStringAsFixed(2)}

// SPHERE
breathingSpeed: ${_sphere.breathingSpeed.toStringAsFixed(2)}
breathingIntensity: ${_sphere.breathingIntensity.toStringAsFixed(2)}
''';
  }
}
