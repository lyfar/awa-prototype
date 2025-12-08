import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../soul/awa_soul_settings.dart';
import 'debug_panel_theme.dart';
import 'debug_ui_builders.dart';

/// 2D Backdrop layer settings tab
class Debug2DTab extends StatelessWidget {
  final AwaSoulSettings settings;
  final DebugUIBuilders ui;
  final void Function(Color) openColorPicker;

  const Debug2DTab({
    super.key,
    required this.settings,
    required this.ui,
    required this.openColorPicker,
  });

  @override
  Widget build(BuildContext context) {
    final s = settings.layer2D;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Layer toggle
        ui.buildLayerToggle('2D Backdrop Layer', Icons.gradient, s.enabled,
            (v) => settings.update2D((s) => s.copyWith(enabled: v))),
        const SizedBox(height: 8),

        // Size & Count
        ui.buildSection(
          id: '2d_size',
          title: 'Size & Count',
          icon: Icons.grain,
          color: Colors.blue,
          children: [
            ui.buildSlider('Dots', s.dotCount.toDouble(), 50, 500,
                (v) => settings.update2D((s) => s.copyWith(dotCount: v.round()))),
            ui.buildSlider('Size', s.dotSize, 1, 12,
                (v) => settings.update2D((s) => s.copyWith(dotSize: v))),
            ui.buildSlider('Variation', s.sizeVariation, 0, 1,
                (v) => settings.update2D((s) => s.copyWith(sizeVariation: v))),
            ui.buildSlider('Center Scale', s.centerScale, 0.3, 1.5,
                (v) => settings.update2D((s) => s.copyWith(centerScale: v))),
            ui.buildSlider('Edge Fade', s.edgeFade, 0, 1,
                (v) => settings.update2D((s) => s.copyWith(edgeFade: v))),
          ],
        ),

        // Opacity & Glow
        ui.buildSection(
          id: '2d_opacity',
          title: 'Opacity & Glow',
          icon: Icons.opacity,
          color: Colors.cyan,
          children: [
            ui.buildSlider('Opacity', s.opacity, 0, 1,
                (v) => settings.update2D((s) => s.copyWith(opacity: v))),
            ui.buildSlider('Center Boost', s.centerOpacity, 0, 0.6,
                (v) => settings.update2D((s) => s.copyWith(centerOpacity: v))),
            ui.buildSlider('Glow', s.glowIntensity, 0, 1,
                (v) => settings.update2D((s) => s.copyWith(glowIntensity: v))),
            ui.buildSlider('Glow Size', s.glowSize, 1, 4,
                (v) => settings.update2D((s) => s.copyWith(glowSize: v))),
            ui.buildSlider('Inner Glow', s.innerGlow, 0, 1,
                (v) => settings.update2D((s) => s.copyWith(innerGlow: v))),
          ],
        ),

        // Motion
        ui.buildSection(
          id: '2d_motion',
          title: 'Motion',
          icon: Icons.autorenew,
          color: Colors.purple,
          children: [
            ui.buildEnumPicker<MotionPattern>('Pattern', s.motionPattern, MotionPattern.values,
                (v) => settings.update2D((s) => s.copyWith(motionPattern: v))),
            ui.buildSlider('Drift Speed', s.driftSpeed, 0, 2,
                (v) => settings.update2D((s) => s.copyWith(driftSpeed: v))),
            ui.buildSlider('Drift Range', s.driftIntensity, 0, 3,
                (v) => settings.update2D((s) => s.copyWith(driftIntensity: v))),
            ui.buildSlider('Rotation', s.rotationSpeed, -0.5, 0.5,
                (v) => settings.update2D((s) => s.copyWith(rotationSpeed: v))),
          ],
        ),

        // Blink / Pulse
        ui.buildSection(
          id: '2d_blink',
          title: 'Blink / Pulse',
          icon: Icons.lightbulb_outline,
          color: Colors.yellow,
          children: [
            ui.buildEnumPicker<FlickerMode>('Mode', s.blinkMode, FlickerMode.values,
                (v) => settings.update2D((s) => s.copyWith(blinkMode: v))),
            ui.buildSlider('Speed', s.blinkSpeed, 0.1, 3,
                (v) => settings.update2D((s) => s.copyWith(blinkSpeed: v))),
            ui.buildSlider('Intensity', s.blinkIntensity, 0, 0.5,
                (v) => settings.update2D((s) => s.copyWith(blinkIntensity: v))),
            ui.buildToggle('Sync All', s.syncBlink,
                (v) => settings.update2D((s) => s.copyWith(syncBlink: v))),
          ],
        ),

        // Spiral
        ui.buildSection(
          id: '2d_spiral',
          title: 'Spiral',
          icon: Icons.rotate_right,
          color: Colors.indigo,
          children: [
            ui.buildSlider('Tightness', s.spiralTightness, 0.5, 2,
                (v) => settings.update2D((s) => s.copyWith(spiralTightness: v))),
            ui.buildSlider('Expansion', s.spiralExpansion, -0.3, 0.3,
                (v) => settings.update2D((s) => s.copyWith(spiralExpansion: v))),
          ],
        ),

        // Gradient Colors
        ui.buildSection(
          id: '2d_colors',
          title: 'Gradient Colors',
          icon: Icons.palette,
          color: Colors.deepOrange,
          children: [
            ui.buildColorRow('Center', s.gradientStart,
                () => openColorPicker(s.gradientStart)),
            ui.buildColorRow('Middle', s.gradientMid,
                () => openColorPicker(s.gradientMid)),
            ui.buildColorRow('Edge', s.gradientEnd,
                () => openColorPicker(s.gradientEnd)),
          ],
        ),

        // Color Palettes
        ui.buildSection(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ui.buildRandomPaletteButton(
          'Random 2D Colors',
          [Colors.cyan, Colors.blue, Colors.purple],
          _applyRandom2DPalette,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: colorPalettes.map((palette) => 
            ui.buildPaletteTile(palette, () => _apply2DColorPalette(palette.colors))
          ).toList(),
        ),
      ],
    );
  }

  void _apply2DColorPalette(List<Color> colors) {
    if (colors.length >= 3) {
      settings.update2D((s) => s.copyWith(
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
      case 0:
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.7).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 30) % 360, 0.7, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 60) % 360, 0.7, 0.5).toColor(),
        ];
        break;
      case 1:
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.7).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 180) % 360, 0.6, 0.5).toColor(),
        ];
        break;
      case 2:
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.7).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 120) % 360, 0.65, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 240) % 360, 0.6, 0.5).toColor(),
        ];
        break;
      default:
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.5, 0.75).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.55).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.4).toColor(),
        ];
    }

    _apply2DColorPalette(colors);
  }
}

