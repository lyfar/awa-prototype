import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../soul/awa_sphere.dart';
import '../../../soul/awa_soul_settings.dart';

/// Color palette data class for color theory presets
class _ColorPalette {
  final String name;
  final List<Color> colors;
  final String theory;
  
  const _ColorPalette(this.name, this.colors, this.theory);
}

/// Full-screen AwaSoul debug page with layer-based controls
/// Features a sliding panel that minimizes visual obstruction
class AwaSoulDebugScreen extends StatefulWidget {
  const AwaSoulDebugScreen({super.key});

  @override
  State<AwaSoulDebugScreen> createState() => _AwaSoulDebugScreenState();
}

/// Theme colors for adaptive UI
class _PanelTheme {
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
  
  const _PanelTheme._({
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
  
  factory _PanelTheme.dark() => const _PanelTheme._(
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
  
  factory _PanelTheme.light() => const _PanelTheme._(
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
}

class _AwaSoulDebugScreenState extends State<AwaSoulDebugScreen>
    with SingleTickerProviderStateMixin {
  final _settings = AwaSoulSettings();
  
  // Panel state
  double _panelHeight = 0.35; // 35% of screen by default
  static const double _minPanel = 0.12;
  static const double _maxPanel = 0.65;
  
  // Layer tab
  int _selectedLayer = 0; // 0=3D, 1=2D, 2=Sphere
  
  // Expanded section within current layer
  String? _expandedSection;
  
  // Current theme based on background
  _PanelTheme get _theme => _settings.sphere.isDarkBackground 
      ? _PanelTheme.dark() 
      : _PanelTheme.light();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  void _copySettings() {
    Clipboard.setData(ClipboardData(text: _settings.exportSettings()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings copied!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeightPx = screenHeight * _panelHeight;
    final sphereHeight = screenHeight - panelHeightPx - MediaQuery.of(context).padding.top - 50;
    final bgColor = _settings.sphere.backgroundColor;
    final isDark = _settings.sphere.isDarkBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // === SPHERE PREVIEW (fills remaining space) ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: panelHeightPx,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildMinimalHeader(isDark),
                  Expanded(
                    child: _buildSpherePreview(sphereHeight),
                  ),
                ],
              ),
            ),
          ),

          // === SLIDING CONTROL PANEL ===
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: panelHeightPx,
            child: GestureDetector(
              onVerticalDragUpdate: _onPanelDrag,
              child: _buildControlPanel(isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanelDrag(DragUpdateDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    setState(() {
      _panelHeight -= details.delta.dy / screenHeight;
      _panelHeight = _panelHeight.clamp(_minPanel, _maxPanel);
    });
  }

  Widget _buildMinimalHeader(bool isDark) {
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final iconColor = isDark ? Colors.white54 : Colors.black54;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: iconColor, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'AwaSoul Lab',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, color: iconColor.withValues(alpha: 0.6), size: 18),
            onPressed: _copySettings,
            tooltip: 'Copy settings',
          ),
          TextButton(
            onPressed: () {
              if (_selectedLayer == 0) {
                _settings.reset3D();
              } else if (_selectedLayer == 1) {
                _settings.reset2D();
              } else {
                _settings.resetToDefaults();
              }
            },
            child: const Text('Reset', style: TextStyle(fontSize: 12, color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpherePreview(double height) {
    return AwaSphere(
      height: height,
      useGlobalSettings: true,
      interactive: true,
    );
  }

  Widget _buildControlPanel(bool isDark) {
    final t = _theme;
    
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          
          // Layer tabs
          _buildLayerTabs(),
          
          Divider(color: t.divider, height: 1),
          
          // Settings content
          Expanded(
            child: _buildLayerSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerTabs() {
    final t = _theme;
    final tabs = [
      ('3D', Icons.blur_on, _settings.layer3D.enabled),
      ('2D', Icons.gradient, _settings.layer2D.enabled),
      ('Sphere', Icons.circle_outlined, true),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final (label, icon, enabled) = entry.value;
          final isSelected = _selectedLayer == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedLayer = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? t.surfaceAlt : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.orange.withValues(alpha: 0.5) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.orange : (enabled ? t.textSecondary : t.textMuted),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? t.text : t.textSecondary,
                      ),
                    ),
                    if (index < 2) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            _settings.update3D((s) => s.copyWith(enabled: !s.enabled));
                          } else {
                            _settings.update2D((s) => s.copyWith(enabled: !s.enabled));
                          }
                        },
                        child: Icon(
                          enabled ? Icons.visibility : Icons.visibility_off,
                          size: 14,
                          color: enabled ? Colors.green : t.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLayerSettings() {
    switch (_selectedLayer) {
      case 0:
        return _build3DSettings();
      case 1:
        return _build2DSettings();
      case 2:
        return _buildSphereSettings();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================================================
  // 3D PARTICLE SETTINGS
  // ==========================================================================
  Widget _build3DSettings() {
    final s = _settings.layer3D;
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Layer toggle at top
        _buildLayerToggle('3D Particles Layer', Icons.blur_on, s.enabled,
            (v) => _settings.update3D((s) => s.copyWith(enabled: v))),
        const SizedBox(height: 8),
        
        _buildSection(
          id: '3d_size',
          title: 'Size & Count',
          icon: Icons.circle,
          color: Colors.blue,
          children: [
            _buildSlider('Count', s.particleCount.toDouble(), 50, 800,
                (v) => _settings.update3D((s) => s.copyWith(particleCount: v.round()))),
            _buildSlider('Size', s.particleSize, 1, 12,
                (v) => _settings.update3D((s) => s.copyWith(particleSize: v))),
            _buildSlider('Size Variation', s.sizeVariation, 0, 1,
                (v) => _settings.update3D((s) => s.copyWith(sizeVariation: v))),
            _buildSlider('Depth Scaling', s.depthScaling, 0, 1,
                (v) => _settings.update3D((s) => s.copyWith(depthScaling: v))),
          ],
        ),
        
        _buildSection(
          id: '3d_light',
          title: 'Light & Glow',
          icon: Icons.wb_sunny,
          color: Colors.amber,
          children: [
            _buildSlider('Emissive', s.emissiveIntensity, 0.5, 5,
                (v) => _settings.update3D((s) => s.copyWith(emissiveIntensity: v))),
            _buildSlider('Core Bright', s.coreIntensity, 0.5, 6,
                (v) => _settings.update3D((s) => s.copyWith(coreIntensity: v))),
            _buildSlider('Glow Radius', s.glowRadius, 0.5, 4,
                (v) => _settings.update3D((s) => s.copyWith(glowRadius: v))),
            _buildSlider('Glow Soft', s.glowSoftness, 2, 30,
                (v) => _settings.update3D((s) => s.copyWith(glowSoftness: v))),
            _buildSlider('Halo', s.haloOpacity, 0, 1,
                (v) => _settings.update3D((s) => s.copyWith(haloOpacity: v))),
            _buildToggle('Additive Blend', s.additiveBlending,
                (v) => _settings.update3D((s) => s.copyWith(additiveBlending: v))),
          ],
        ),
        
        _buildSection(
          id: '3d_motion',
          title: 'Motion',
          icon: Icons.animation,
          color: Colors.purple,
          children: [
            _buildEnumPicker<MotionPattern>('Pattern', s.motionPattern, MotionPattern.values,
                (v) => _settings.update3D((s) => s.copyWith(motionPattern: v))),
            _buildSlider('Drift Speed', s.driftSpeed, 0, 3,
                (v) => _settings.update3D((s) => s.copyWith(driftSpeed: v))),
            _buildSlider('Drift Range', s.driftIntensity, 0, 5,
                (v) => _settings.update3D((s) => s.copyWith(driftIntensity: v))),
          ],
        ),
        
        _buildSection(
          id: '3d_wiggle',
          title: 'Wiggle',
          icon: Icons.waves,
          color: Colors.teal,
          children: [
            _buildEnumPicker<WiggleStyle>('Style', s.wiggleStyle, WiggleStyle.values,
                (v) => _settings.update3D((s) => s.copyWith(wiggleStyle: v))),
            _buildSlider('Speed', s.wiggleSpeed, 0.1, 3,
                (v) => _settings.update3D((s) => s.copyWith(wiggleSpeed: v))),
            _buildSlider('Intensity', s.wiggleIntensity, 0, 0.5,
                (v) => _settings.update3D((s) => s.copyWith(wiggleIntensity: v))),
          ],
        ),
        
        _buildSection(
          id: '3d_flicker',
          title: 'Flicker & Pulse',
          icon: Icons.flash_on,
          color: Colors.orange,
          children: [
            _buildEnumPicker<FlickerMode>('Flicker', s.flickerMode, FlickerMode.values,
                (v) => _settings.update3D((s) => s.copyWith(flickerMode: v))),
            _buildSlider('Flicker Speed', s.flickerSpeed, 0.2, 5,
                (v) => _settings.update3D((s) => s.copyWith(flickerSpeed: v))),
            _buildSlider('Flicker Amount', s.flickerIntensity, 0, 0.5,
                (v) => _settings.update3D((s) => s.copyWith(flickerIntensity: v))),
            const Divider(color: Colors.white10),
            _buildSlider('Pulse Speed', s.pulseSpeed, 0.2, 5,
                (v) => _settings.update3D((s) => s.copyWith(pulseSpeed: v))),
            _buildSlider('Pulse Amount', s.pulseIntensity, 0, 0.5,
                (v) => _settings.update3D((s) => s.copyWith(pulseIntensity: v))),
            _buildToggle('Sync Pulse', s.syncPulse,
                (v) => _settings.update3D((s) => s.copyWith(syncPulse: v))),
          ],
        ),
        
        _buildSection(
          id: '3d_bloom',
          title: 'Bloom',
          icon: Icons.flare,
          color: Colors.pink,
          children: [
            _buildToggle('Enable', s.enableBloom,
                (v) => _settings.update3D((s) => s.copyWith(enableBloom: v))),
            if (s.enableBloom) ...[
              _buildSlider('Intensity', s.bloomIntensity, 0.1, 1.5,
                  (v) => _settings.update3D((s) => s.copyWith(bloomIntensity: v))),
              _buildSlider('Radius', s.bloomRadius, 4, 30,
                  (v) => _settings.update3D((s) => s.copyWith(bloomRadius: v))),
            ],
          ],
        ),
        
        _buildSection(
          id: '3d_color',
          title: 'Particle Colors',
          icon: Icons.palette,
          color: Colors.deepOrange,
          children: [
            Text('Core = brightest center, Outer = edge glow', 
                style: TextStyle(fontSize: 10, color: _theme.textMuted)),
            const SizedBox(height: 8),
            _buildColorRow('Core (bright)', s.coreColor,
                (c) => _settings.update3D((s) => s.copyWith(coreColor: c))),
            _buildColorRow('Mid', s.midColor,
                (c) => _settings.update3D((s) => s.copyWith(midColor: c))),
            _buildColorRow('Outer (glow)', s.outerColor,
                (c) => _settings.update3D((s) => s.copyWith(outerColor: c))),
          ],
        ),
        
        // 3D Color Palettes
        _buildSection(
          id: '3d_palettes',
          title: 'Color Palettes',
          icon: Icons.color_lens,
          color: Colors.pink,
          children: [
            _build3DPaletteGrid(),
          ],
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _build3DPaletteGrid() {
    final t = _theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Random button for 3D
        GestureDetector(
          onTap: _applyRandom3DPalette,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.3),
                  Colors.red.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shuffle, size: 18, color: t.text),
                const SizedBox(width: 8),
                Text('Random 3D Colors', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.text)),
              ],
            ),
          ),
        ),
        
        // 3D specific palettes
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _colorPalettes.map((palette) => _build3DPaletteTile(palette)).toList(),
        ),
      ],
    );
  }

  Widget _build3DPaletteTile(_ColorPalette palette) {
    final t = _theme;
    return GestureDetector(
      onTap: () => _apply3DColorPalette(palette.colors),
      child: Tooltip(
        message: palette.theory,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: t.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Row(
                  children: palette.colors.map((c) => Expanded(
                    child: Container(color: c),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              palette.name,
              style: TextStyle(fontSize: 9, color: t.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _apply3DColorPalette(List<Color> colors) {
    if (colors.length >= 3) {
      _settings.update3D((s) => s.copyWith(
        coreColor: _lightenColor(colors[0], 0.3),
        midColor: colors[1],
        outerColor: colors[2],
      ));
    }
  }

  void _applyRandom3DPalette() {
    final random = math.Random();
    final baseHue = random.nextDouble() * 360;
    final harmonyType = random.nextInt(5);
    
    List<Color> colors;
    switch (harmonyType) {
      case 0: // Analogous
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.85).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 30) % 360, 0.7, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 60) % 360, 0.7, 0.5).toColor(),
        ];
        break;
      case 1: // Complementary
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.85).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 180) % 360, 0.6, 0.5).toColor(),
        ];
        break;
      case 2: // Triadic
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.85).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 120) % 360, 0.65, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 240) % 360, 0.6, 0.5).toColor(),
        ];
        break;
      default: // Monochromatic warm
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.4, 0.9).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.65).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.45).toColor(),
        ];
    }
    
    _apply3DColorPalette(colors);
  }

  // ==========================================================================
  // 2D BACKDROP SETTINGS
  // ==========================================================================
  Widget _build2DSettings() {
    final s = _settings.layer2D;
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Layer toggle at top
        _buildLayerToggle('2D Backdrop Layer', Icons.gradient, s.enabled,
            (v) => _settings.update2D((s) => s.copyWith(enabled: v))),
        const SizedBox(height: 8),
        
        _buildSection(
          id: '2d_size',
          title: 'Size & Count',
          icon: Icons.grain,
          color: Colors.blue,
          children: [
            _buildSlider('Dots', s.dotCount.toDouble(), 50, 500,
                (v) => _settings.update2D((s) => s.copyWith(dotCount: v.round()))),
            _buildSlider('Size', s.dotSize, 1, 12,
                (v) => _settings.update2D((s) => s.copyWith(dotSize: v))),
            _buildSlider('Variation', s.sizeVariation, 0, 1,
                (v) => _settings.update2D((s) => s.copyWith(sizeVariation: v))),
            _buildSlider('Center Scale', s.centerScale, 0.3, 1.5,
                (v) => _settings.update2D((s) => s.copyWith(centerScale: v))),
            _buildSlider('Edge Fade', s.edgeFade, 0, 1,
                (v) => _settings.update2D((s) => s.copyWith(edgeFade: v))),
          ],
        ),
        
        _buildSection(
          id: '2d_opacity',
          title: 'Opacity & Glow',
          icon: Icons.opacity,
          color: Colors.cyan,
          children: [
            _buildSlider('Opacity', s.opacity, 0, 1,
                (v) => _settings.update2D((s) => s.copyWith(opacity: v))),
            _buildSlider('Center Boost', s.centerOpacity, 0, 0.6,
                (v) => _settings.update2D((s) => s.copyWith(centerOpacity: v))),
            _buildSlider('Glow', s.glowIntensity, 0, 1,
                (v) => _settings.update2D((s) => s.copyWith(glowIntensity: v))),
            _buildSlider('Glow Size', s.glowSize, 1, 4,
                (v) => _settings.update2D((s) => s.copyWith(glowSize: v))),
            _buildSlider('Inner Glow', s.innerGlow, 0, 1,
                (v) => _settings.update2D((s) => s.copyWith(innerGlow: v))),
          ],
        ),
        
        _buildSection(
          id: '2d_motion',
          title: 'Motion',
          icon: Icons.autorenew,
          color: Colors.purple,
          children: [
            _buildEnumPicker<MotionPattern>('Pattern', s.motionPattern, MotionPattern.values,
                (v) => _settings.update2D((s) => s.copyWith(motionPattern: v))),
            _buildSlider('Drift Speed', s.driftSpeed, 0, 2,
                (v) => _settings.update2D((s) => s.copyWith(driftSpeed: v))),
            _buildSlider('Drift Range', s.driftIntensity, 0, 3,
                (v) => _settings.update2D((s) => s.copyWith(driftIntensity: v))),
            _buildSlider('Rotation', s.rotationSpeed, -0.5, 0.5,
                (v) => _settings.update2D((s) => s.copyWith(rotationSpeed: v))),
          ],
        ),
        
        _buildSection(
          id: '2d_blink',
          title: 'Blink / Pulse',
          icon: Icons.lightbulb_outline,
          color: Colors.yellow,
          children: [
            _buildEnumPicker<FlickerMode>('Mode', s.blinkMode, FlickerMode.values,
                (v) => _settings.update2D((s) => s.copyWith(blinkMode: v))),
            _buildSlider('Speed', s.blinkSpeed, 0.1, 3,
                (v) => _settings.update2D((s) => s.copyWith(blinkSpeed: v))),
            _buildSlider('Intensity', s.blinkIntensity, 0, 0.5,
                (v) => _settings.update2D((s) => s.copyWith(blinkIntensity: v))),
            _buildToggle('Sync All', s.syncBlink,
                (v) => _settings.update2D((s) => s.copyWith(syncBlink: v))),
          ],
        ),
        
        _buildSection(
          id: '2d_spiral',
          title: 'Spiral',
          icon: Icons.rotate_right,
          color: Colors.indigo,
          children: [
            _buildSlider('Tightness', s.spiralTightness, 0.5, 2,
                (v) => _settings.update2D((s) => s.copyWith(spiralTightness: v))),
            _buildSlider('Expansion', s.spiralExpansion, -0.3, 0.3,
                (v) => _settings.update2D((s) => s.copyWith(spiralExpansion: v))),
          ],
        ),
        
        _buildSection(
          id: '2d_colors',
          title: 'Gradient Colors',
          icon: Icons.palette,
          color: Colors.deepOrange,
          children: [
            _buildColorRow('Center', s.gradientStart,
                (c) => _settings.update2D((s) => s.copyWith(gradientStart: c))),
            _buildColorRow('Middle', s.gradientMid,
                (c) => _settings.update2D((s) => s.copyWith(gradientMid: c))),
            _buildColorRow('Edge', s.gradientEnd,
                (c) => _settings.update2D((s) => s.copyWith(gradientEnd: c))),
          ],
        ),
        
        // 2D Color Palettes
        _buildSection(
          id: '2d_palettes',
          title: 'Color Palettes',
          icon: Icons.color_lens,
          color: Colors.pink,
          children: [
            _build2DPaletteGrid(),
          ],
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _build2DPaletteGrid() {
    final t = _theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Random button for 2D
        GestureDetector(
          onTap: _applyRandom2DPalette,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.withValues(alpha: 0.3),
                  Colors.blue.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shuffle, size: 18, color: t.text),
                const SizedBox(width: 8),
                Text('Random 2D Colors', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.text)),
              ],
            ),
          ),
        ),
        
        // 2D specific palettes
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _colorPalettes.map((palette) => _build2DPaletteTile(palette)).toList(),
        ),
      ],
    );
  }

  Widget _build2DPaletteTile(_ColorPalette palette) {
    final t = _theme;
    return GestureDetector(
      onTap: () => _apply2DColorPalette(palette.colors),
      child: Tooltip(
        message: palette.theory,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: t.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Row(
                  children: palette.colors.map((c) => Expanded(
                    child: Container(color: c),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              palette.name,
              style: TextStyle(fontSize: 9, color: t.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _apply2DColorPalette(List<Color> colors) {
    if (colors.length >= 3) {
      _settings.update2D((s) => s.copyWith(
        gradientStart: colors[0],
        gradientMid: colors[1],
        gradientEnd: colors[2],
      ));
    }
  }

  void _applyRandom2DPalette() {
    final random = math.Random();
    final baseHue = random.nextDouble() * 360;
    final harmonyType = random.nextInt(5);
    
    List<Color> colors;
    switch (harmonyType) {
      case 0: // Analogous
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.7).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 30) % 360, 0.7, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 60) % 360, 0.7, 0.5).toColor(),
        ];
        break;
      case 1: // Complementary
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.7).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 180) % 360, 0.6, 0.5).toColor(),
        ];
        break;
      case 2: // Triadic
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.7).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 120) % 360, 0.65, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 240) % 360, 0.6, 0.5).toColor(),
        ];
        break;
      default: // Monochromatic
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.5, 0.75).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.55).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.4).toColor(),
        ];
    }
    
    _apply2DColorPalette(colors);
  }

  // ==========================================================================
  // SPHERE SETTINGS (Global / Canvas settings only)
  // ==========================================================================
  Widget _buildSphereSettings() {
    final s = _settings.sphere;
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Background section - this is the main canvas
        _buildSection(
          id: 'sphere_bg',
          title: 'Background',
          icon: Icons.format_paint,
          color: Colors.deepPurple,
          children: [
            _buildBackgroundPresetPicker(s.backgroundPreset),
            if (s.backgroundPreset == BackgroundPreset.custom) ...[
              const SizedBox(height: 8),
              _buildColorRow('Custom', s.customBackgroundColor,
                  (c) => _settings.updateSphere((s) => s.copyWith(customBackgroundColor: c))),
            ],
          ],
        ),
        
        // Global breathing/scale
        _buildSection(
          id: 'sphere_breath',
          title: 'Breathing',
          icon: Icons.air,
          color: Colors.teal,
          children: [
            _buildSlider('Speed', s.breathingSpeed, 0.1, 1,
                (v) => _settings.updateSphere((s) => s.copyWith(breathingSpeed: v))),
            _buildSlider('Intensity', s.breathingIntensity, 0, 3,
                (v) => _settings.updateSphere((s) => s.copyWith(breathingIntensity: v))),
            _buildSlider('Base Scale', s.baseScale, 0.5, 1.5,
                (v) => _settings.updateSphere((s) => s.copyWith(baseScale: v))),
          ],
        ),
        
        // Quick presets
        _buildSection(
          id: 'sphere_presets',
          title: 'Quick Presets',
          icon: Icons.auto_awesome,
          color: Colors.amber,
          children: [
            _buildPresetTile('Calm', 'Gentle, soft glow', () {
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.gentle,
                flickerSpeed: 1.5,
                pulseSpeed: 1.5,
                emissiveIntensity: 2.0,
                wiggleStyle: WiggleStyle.subtle,
              );
              _settings.layer2D = Layer2DSettings(
                blinkMode: FlickerMode.gentle,
                blinkSpeed: 0.4,
                opacity: 0.4,
              );
              _settings.sphere = SphereSettings(
                breathingIntensity: 1.2,
                backgroundPreset: BackgroundPreset.black,
              );
            }),
            _buildPresetTile('Energetic', 'Bright, lively motion', () {
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.sparkle,
                flickerSpeed: 3.5,
                pulseSpeed: 3.5,
                emissiveIntensity: 4.0,
                wiggleStyle: WiggleStyle.electric,
                driftSpeed: 2.0,
              );
              _settings.layer2D = Layer2DSettings(
                blinkMode: FlickerMode.sparkle,
                blinkSpeed: 1.5,
                opacity: 0.7,
              );
              _settings.sphere = SphereSettings(
                breathingIntensity: 2.5,
                backgroundPreset: BackgroundPreset.midnight,
              );
            }),
            _buildPresetTile('Meditation', 'Slow, rhythmic pulse', () {
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.off,
                pulseSpeed: 0.8,
                pulseIntensity: 0.2,
                syncPulse: true,
                emissiveIntensity: 2.5,
                wiggleStyle: WiggleStyle.none,
              );
              _settings.layer2D = Layer2DSettings(
                blinkMode: FlickerMode.off,
                blinkSpeed: 0.3,
                syncBlink: true,
              );
              _settings.sphere = SphereSettings(
                breathingIntensity: 2.0,
                breathingSpeed: 0.2,
                backgroundPreset: BackgroundPreset.black,
              );
            }),
            _buildPresetTile('Fire', 'Candle-like flicker', () {
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.candle,
                flickerSpeed: 4.0,
                flickerIntensity: 0.3,
                emissiveIntensity: 3.5,
                coreColor: const Color(0xFFFFFAE0),
                midColor: const Color(0xFFFFB040),
                outerColor: const Color(0xFFE85020),
              );
              _settings.layer2D = Layer2DSettings(
                gradientStart: const Color(0xFFFFD080),
                gradientMid: const Color(0xFFFF8040),
                gradientEnd: const Color(0xFFCC4020),
                blinkMode: FlickerMode.candle,
              );
              _settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.warmDark);
            }),
            _buildPresetTile('Ocean Dream', 'Cool, flowing waves', () {
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.wave,
                flickerSpeed: 1.5,
                flickerIntensity: 0.2,
                emissiveIntensity: 2.5,
                coreColor: const Color(0xFFE0F8FF),
                midColor: const Color(0xFF60C0E0),
                outerColor: const Color(0xFF3080A0),
                motionPattern: MotionPattern.swirl,
                wiggleStyle: WiggleStyle.fluid,
              );
              _settings.layer2D = Layer2DSettings(
                gradientStart: const Color(0xFF80D0F0),
                gradientMid: const Color(0xFF4090C0),
                gradientEnd: const Color(0xFF206080),
                blinkMode: FlickerMode.wave,
              );
              _settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.ocean);
            }),
            _buildPresetTile('Pure Light', 'Clean white canvas', () {
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.gentle,
                flickerSpeed: 1.0,
                emissiveIntensity: 1.5,
                coreColor: const Color(0xFFFFEEDD),
                midColor: const Color(0xFFFFCCBB),
                outerColor: const Color(0xFFDDA0A0),
              );
              _settings.layer2D = Layer2DSettings(
                gradientStart: const Color(0xFFFFD4C4),
                gradientMid: const Color(0xFFFFB8A8),
                gradientEnd: const Color(0xFFE8A090),
                opacity: 0.3,
              );
              _settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.white);
            }),
            _buildPresetTile('Intense Sunset', '12-tone sunset spectrum', () {
              // Using the intense sunset palette colors
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.candle,
                flickerSpeed: 2.5,
                flickerIntensity: 0.25,
                emissiveIntensity: 3.5,
                coreColor: const Color(0xFFFF6A14), // огненное касание солнца
                midColor: const Color(0xFFF91A4D),  // алый с электричеством
                outerColor: const Color(0xFF6A05B9), // фиолетовое послесвечение
                motionPattern: MotionPattern.organic,
                wiggleStyle: WiggleStyle.fluid,
                driftSpeed: 1.2,
              );
              _settings.layer2D = Layer2DSettings(
                gradientStart: const Color(0xFFFF541F), // яркая апельсиновая вспышка
                gradientMid: const Color(0xFFDD0F6F),   // горячий фуксия
                gradientEnd: const Color(0xFF8807A8),   // вечерний фиолетовый
                blinkMode: FlickerMode.wave,
                blinkSpeed: 0.8,
                opacity: 0.65,
              );
              _settings.sphere = SphereSettings(
                backgroundPreset: BackgroundPreset.black,
                breathingIntensity: 1.5,
              );
            }),
            _buildPresetTile('Sunset Warm', 'Fire and coral tones', () {
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.candle,
                flickerSpeed: 3.0,
                emissiveIntensity: 3.0,
                coreColor: const Color(0xFFFFFFE0), // hot white center
                midColor: const Color(0xFFFF6A14),  // огненное касание
                outerColor: const Color(0xFFFF263D), // неоновый мак
              );
              _settings.layer2D = Layer2DSettings(
                gradientStart: const Color(0xFFFF6A14),
                gradientMid: const Color(0xFFFF3533),
                gradientEnd: const Color(0xFFEB125F),
                blinkMode: FlickerMode.candle,
              );
              _settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.warmDark);
            }),
            _buildPresetTile('Sunset Cool', 'Purple afterglow', () {
              _settings.layer3D = Layer3DSettings(
                flickerMode: FlickerMode.gentle,
                flickerSpeed: 1.5,
                emissiveIntensity: 2.5,
                coreColor: const Color(0xFFEB125F), // малиновый импульс
                midColor: const Color(0xFFA40A97),  // насыщенный пурпур
                outerColor: const Color(0xFF6A05B9), // фиолетовое послесвечение
                motionPattern: MotionPattern.breathe,
              );
              _settings.layer2D = Layer2DSettings(
                gradientStart: const Color(0xFFDD0F6F),
                gradientMid: const Color(0xFFA40A97),
                gradientEnd: const Color(0xFF6A05B9),
                blinkMode: FlickerMode.gentle,
                blinkSpeed: 0.5,
              );
              _settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.midnight);
            }),
          ],
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _buildLayerToggle(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    final t = _theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: value ? Colors.orange : t.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: value ? t.text : t.textSecondary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
            inactiveTrackColor: t.border,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // Color theory palettes
  static const List<_ColorPalette> _colorPalettes = [
    // === INTENSE SUNSET PALETTE (12-tone derived) ===
    // огненное касание солнца → фиолетовое послесвечение
    _ColorPalette('Sunset Fire', [Color(0xFFFF6A14), Color(0xFFFF541F), Color(0xFFFF442A)], '🌅 Intense orange'),
    _ColorPalette('Sunset Blaze', [Color(0xFFFF541F), Color(0xFFFF3533), Color(0xFFFF263D)], '🌅 Orange to red'),
    _ColorPalette('Sunset Coral', [Color(0xFFFF442A), Color(0xFFFF263D), Color(0xFFF91A4D)], '🌅 Coral heat'),
    _ColorPalette('Sunset Neon', [Color(0xFFFF3533), Color(0xFFF91A4D), Color(0xFFEB125F)], '🌅 Neon poppy'),
    _ColorPalette('Sunset Rose', [Color(0xFFF91A4D), Color(0xFFDD0F6F), Color(0xFFC50C82)], '🌅 Electric rose'),
    _ColorPalette('Sunset Fuchsia', [Color(0xFFEB125F), Color(0xFFC50C82), Color(0xFFA40A97)], '🌅 Hot fuchsia'),
    _ColorPalette('Sunset Violet', [Color(0xFFDD0F6F), Color(0xFFA40A97), Color(0xFF8807A8)], '🌅 Purple wave'),
    _ColorPalette('Sunset Glow', [Color(0xFFC50C82), Color(0xFF8807A8), Color(0xFF6A05B9)], '🌅 Afterglow'),
    // Full sunset spectrum picks
    _ColorPalette('Sunset Full', [Color(0xFFFF6A14), Color(0xFFF91A4D), Color(0xFF6A05B9)], '🌅 Full spectrum'),
    _ColorPalette('Sunset Warm', [Color(0xFFFF6A14), Color(0xFFFF3533), Color(0xFFEB125F)], '🌅 Warm half'),
    _ColorPalette('Sunset Cool', [Color(0xFFDD0F6F), Color(0xFFA40A97), Color(0xFF6A05B9)], '🌅 Cool half'),
    _ColorPalette('Sunset Edge', [Color(0xFFFF6A14), Color(0xFFDD0F6F), Color(0xFF6A05B9)], '🌅 Edge colors'),
    
    // === CLASSIC WARM ===
    _ColorPalette('Peach Dream', [Color(0xFFFFD7C0), Color(0xFFFFA573), Color(0xFFFF7BC5)], 'Analogous coral'),
    _ColorPalette('Rose Garden', [Color(0xFFFFB8C6), Color(0xFFE88AAB), Color(0xFFD066A0)], 'Analogous pink'),
    
    // === COOL ===
    _ColorPalette('Ocean', [Color(0xFF48CAE4), Color(0xFF0096C7), Color(0xFF0077B6)], 'Analogous blue'),
    _ColorPalette('Forest', [Color(0xFF95D5B2), Color(0xFF52B788), Color(0xFF2D6A4F)], 'Analogous green'),
    _ColorPalette('Lavender', [Color(0xFFE8D4F0), Color(0xFFC4A8D8), Color(0xFF9B7BB8)], 'Analogous purple'),
    
    // === COMPLEMENTARY ===
    _ColorPalette('Fire & Ice', [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)], 'Complementary'),
    _ColorPalette('Royal', [Color(0xFFFFD700), Color(0xFFF8961E), Color(0xFF6A0DAD)], 'Complementary gold'),
    _ColorPalette('Coral Sea', [Color(0xFFFF7F50), Color(0xFFFFAA85), Color(0xFF20B2AA)], 'Complementary teal'),
    
    // === TRIADIC ===
    _ColorPalette('Primary', [Color(0xFFFF5252), Color(0xFFFFEB3B), Color(0xFF2196F3)], 'Triadic primary'),
    _ColorPalette('Neon', [Color(0xFFFF00FF), Color(0xFF00FFFF), Color(0xFFFFFF00)], 'Triadic neon'),
    _ColorPalette('Earth', [Color(0xFFD4A574), Color(0xFF8B9A46), Color(0xFF5D6D7E)], 'Triadic earth'),
    
    // === SPLIT-COMPLEMENTARY ===
    _ColorPalette('Tropical', [Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1)], 'Split-comp'),
    _ColorPalette('Berry', [Color(0xFF9B59B6), Color(0xFFE74C3C), Color(0xFF3498DB)], 'Split-comp berry'),
    
    // === MONOCHROMATIC ===
    _ColorPalette('Ember', [Color(0xFFFFF0E6), Color(0xFFFFB380), Color(0xFFCC5500)], 'Mono orange'),
    _ColorPalette('Midnight', [Color(0xFFB8C6DB), Color(0xFF63779B), Color(0xFF2C3E50)], 'Mono blue'),
    _ColorPalette('Blush', [Color(0xFFFFF0F5), Color(0xFFFFB6C1), Color(0xFFFF69B4)], 'Mono pink'),
    
    // === SPECIAL ===
    _ColorPalette('Aurora', [Color(0xFF00FF87), Color(0xFF60EFFF), Color(0xFFFF00E5)], 'Northern lights'),
    _ColorPalette('Candy', [Color(0xFFFF6FD8), Color(0xFF00E4FF), Color(0xFFFFFB7D)], 'Sweet pop'),
    _ColorPalette('Cosmos', [Color(0xFFE8D5F2), Color(0xFF9B72CF), Color(0xFF3D1F5C)], 'Deep space'),
  ];

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Widget _buildBackgroundPresetPicker(BackgroundPreset selected) {
    final t = _theme;
    final presets = [
      (BackgroundPreset.black, 'Black', const Color(0xFF000000)),
      (BackgroundPreset.white, 'White', const Color(0xFFFFFFFF)),
      (BackgroundPreset.midnight, 'Midnight', const Color(0xFF0D1117)),
      (BackgroundPreset.warmDark, 'Warm', const Color(0xFF1A1410)),
      (BackgroundPreset.coolGray, 'Gray', const Color(0xFF1C1C1E)),
      (BackgroundPreset.forest, 'Forest', const Color(0xFF0D1A14)),
      (BackgroundPreset.wine, 'Wine', const Color(0xFF1A0D12)),
      (BackgroundPreset.ocean, 'Ocean', const Color(0xFF0A1520)),
      (BackgroundPreset.custom, 'Custom', _settings.sphere.customBackgroundColor),
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) {
        final (type, name, color) = preset;
        final isSelected = selected == type;
        // Check if this preset color is light for border visibility
        final presetLuminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
        final needsDarkBorder = presetLuminance > 0.5;
        
        return GestureDetector(
          onTap: () => _settings.updateSphere((s) => s.copyWith(backgroundPreset: type)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.orange : (needsDarkBorder ? Colors.black38 : t.border),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ] : null,
                ),
                child: type == BackgroundPreset.custom
                    ? Icon(Icons.colorize, size: 16, color: _getContrastColor(color))
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.orange : t.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================================
  // UI BUILDERS
  // ==========================================================================
  
  Widget _buildSection({
    required String id,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final t = _theme;
    final isExpanded = _expandedSection == id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: t.surfaceAlt.withValues(alpha: t.isDark ? 0.5 : 1.0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? color.withValues(alpha: 0.4) : t.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedSection = isExpanded ? null : id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 15, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: t.text,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: t.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    final t = _theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: t.textSecondary),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.orange,
                inactiveTrackColor: t.border,
                thumbColor: Colors.orange,
              ),
              child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
            ),
          ),
          Container(
            width: 40,
            alignment: Alignment.centerRight,
            child: Text(
              value < 10 ? value.toStringAsFixed(2) : value.round().toString(),
              style: TextStyle(fontSize: 11, color: t.textSecondary, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    final t = _theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
            inactiveTrackColor: t.border,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildEnumPicker<T extends Enum>(String label, T value, List<T> values, ValueChanged<T> onChanged) {
    final t = _theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ),
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: values.map((v) {
                final isSelected = v == value;
                return GestureDetector(
                  onTap: () => onChanged(v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.withValues(alpha: 0.3) : t.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? Colors.orange : t.border,
                      ),
                    ),
                    child: Text(
                      v.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.orange : t.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(String label, Color color, ValueChanged<Color> onChanged) {
    final t = _theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ),
          const SizedBox(width: 8),
          ..._colorPresets.map((preset) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChanged(preset),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: preset,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.toARGB32() == preset.toARGB32() ? t.text : t.border,
                    width: color.toARGB32() == preset.toARGB32() ? 2 : 1,
                  ),
                ),
              ),
            ),
          )),
          const Spacer(),
          GestureDetector(
            onTap: () => _openColorPicker(label, color, onChanged),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: t.border),
              ),
              child: Icon(Icons.colorize, size: 14, color: _getContrastColor(color)),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getContrastColor(Color color) {
    final luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
    return luminance > 0.5 ? Colors.black54 : Colors.white70;
  }

  static const List<Color> _colorPresets = [
    Color(0xFFFFD7C0),
    Color(0xFFFFA573),
    Color(0xFFFF8B7A),
    Color(0xFFFF7BC5),
    Color(0xFFD08CF2),
    Color(0xFF88D4E8),
    Color(0xFFFFFAF0),
  ];

  Widget _buildPresetTile(String name, String desc, VoidCallback onTap) {
    final t = _theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: t.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.text)),
                  Text(desc, style: TextStyle(fontSize: 11, color: t.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: t.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _openColorPicker(String label, Color initialColor, ValueChanged<Color> onChanged) async {
    Color tempColor = initialColor;
    final hexController = TextEditingController(text: _colorToHex(initialColor));
    String? hexError;
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A30),
          title: Text('$label color', style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Color preview
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: tempColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Center(
                        child: Text(
                          _colorToHex(tempColor),
                          style: TextStyle(
                            color: _getContrastColor(tempColor),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // HEX input
                    TextField(
                      controller: hexController,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        labelText: 'HEX Color',
                        labelStyle: const TextStyle(color: Colors.white54),
                        hintText: '#FF6A14',
                        hintStyle: const TextStyle(color: Colors.white24),
                        errorText: hexError,
                        prefixIcon: const Icon(Icons.tag, color: Colors.orange, size: 20),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        final parsed = _parseHexColor(value);
                        if (parsed != null) {
                          setState(() {
                            tempColor = parsed;
                            hexError = null;
                          });
                        } else if (value.isNotEmpty) {
                          setState(() {
                            hexError = 'Use format: #RRGGBB or RRGGBB';
                          });
                        }
                      },
                      onSubmitted: (value) {
                        final parsed = _parseHexColor(value);
                        if (parsed != null) {
                          Navigator.of(context).pop();
                          onChanged(parsed);
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    
                    // Quick color swatches
                    Text('Quick Colors', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._colorPresets.map((c) => _buildColorSwatch(c, tempColor, (color) {
                          setState(() {
                            tempColor = color;
                            hexController.text = _colorToHex(color);
                            hexError = null;
                          });
                        })),
                        // Sunset palette highlights
                        _buildColorSwatch(const Color(0xFFFF6A14), tempColor, (color) {
                          setState(() { tempColor = color; hexController.text = _colorToHex(color); });
                        }),
                        _buildColorSwatch(const Color(0xFFF91A4D), tempColor, (color) {
                          setState(() { tempColor = color; hexController.text = _colorToHex(color); });
                        }),
                        _buildColorSwatch(const Color(0xFF6A05B9), tempColor, (color) {
                          setState(() { tempColor = color; hexController.text = _colorToHex(color); });
                        }),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onChanged(tempColor);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
    hexController.dispose();
  }
  
  Widget _buildColorSwatch(Color color, Color selected, ValueChanged<Color> onTap) {
    final isSelected = color.toARGB32() == selected.toARGB32();
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
          ] : null,
        ),
      ),
    );
  }
  
  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
  
  Color? _parseHexColor(String input) {
    var hex = input.trim().toUpperCase();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) {
        return Color(0xFF000000 | value);
      }
    }
    return null;
  }
}
