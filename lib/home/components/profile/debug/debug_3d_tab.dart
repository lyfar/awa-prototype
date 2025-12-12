import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../soul/awa_soul_settings.dart';
import 'debug_panel_theme.dart';
import 'debug_ui_builders.dart';

/// 3D Particle layer settings tab
class Debug3DTab extends StatelessWidget {
  final AwaSoulSettings settings;
  final DebugUIBuilders ui;
  final void Function(Color) openColorPicker;

  const Debug3DTab({
    super.key,
    required this.settings,
    required this.ui,
    required this.openColorPicker,
  });

  @override
  Widget build(BuildContext context) {
    final s = settings.layer3D;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Layer toggle
        ui.buildLayerToggle('3D Particles Layer', Icons.blur_on, s.enabled,
            (v) => settings.update3D((s) => s.copyWith(enabled: v))),
        const SizedBox(height: 8),

        // Size & Count
        ui.buildSection(
          id: '3d_size',
          title: 'Size & Count',
          icon: Icons.circle,
          color: Colors.blue,
          children: [
            ui.buildSlider('Count', s.particleCount.toDouble(), 50, 800,
                (v) => settings.update3D((s) => s.copyWith(particleCount: v.round()))),
            ui.buildSlider('Size', s.particleSize, 1, 12,
                (v) => settings.update3D((s) => s.copyWith(particleSize: v))),
            ui.buildSlider('Size Variation', s.sizeVariation, 0, 1,
                (v) => settings.update3D((s) => s.copyWith(sizeVariation: v))),
            ui.buildSlider('Depth Scaling', s.depthScaling, 0, 1,
                (v) => settings.update3D((s) => s.copyWith(depthScaling: v))),
          ],
        ),

        // Light & Glow
        ui.buildSection(
          id: '3d_light',
          title: 'Light & Glow',
          icon: Icons.wb_sunny,
          color: Colors.amber,
          children: [
            ui.buildSlider('Emissive', s.emissiveIntensity, 0.5, 5,
                (v) => settings.update3D((s) => s.copyWith(emissiveIntensity: v))),
            ui.buildSlider('Core Bright', s.coreIntensity, 0.5, 6,
                (v) => settings.update3D((s) => s.copyWith(coreIntensity: v))),
            ui.buildSlider('Glow Radius', s.glowRadius, 0.5, 4,
                (v) => settings.update3D((s) => s.copyWith(glowRadius: v))),
            ui.buildSlider('Glow Soft', s.glowSoftness, 2, 30,
                (v) => settings.update3D((s) => s.copyWith(glowSoftness: v))),
            ui.buildSlider('Halo', s.haloOpacity, 0, 1,
                (v) => settings.update3D((s) => s.copyWith(haloOpacity: v))),
            ui.buildToggle('Additive Blend', s.additiveBlending,
                (v) => settings.update3D((s) => s.copyWith(additiveBlending: v))),
          ],
        ),

        // Motion
        ui.buildSection(
          id: '3d_motion',
          title: 'Motion',
          icon: Icons.animation,
          color: Colors.purple,
          children: [
            ui.buildEnumPicker<MotionPattern>('Pattern', s.motionPattern, MotionPattern.values,
                (v) => settings.update3D((s) => s.copyWith(motionPattern: v))),
            ui.buildSlider('Drift Speed', s.driftSpeed, 0, 3,
                (v) => settings.update3D((s) => s.copyWith(driftSpeed: v))),
            ui.buildSlider('Drift Range', s.driftIntensity, 0, 5,
                (v) => settings.update3D((s) => s.copyWith(driftIntensity: v))),
          ],
        ),

        // Wiggle
        ui.buildSection(
          id: '3d_wiggle',
          title: 'Wiggle',
          icon: Icons.waves,
          color: Colors.teal,
          children: [
            ui.buildEnumPicker<WiggleStyle>('Style', s.wiggleStyle, WiggleStyle.values,
                (v) => settings.update3D((s) => s.copyWith(wiggleStyle: v))),
            ui.buildSlider('Speed', s.wiggleSpeed, 0.1, 3,
                (v) => settings.update3D((s) => s.copyWith(wiggleSpeed: v))),
            ui.buildSlider('Intensity', s.wiggleIntensity, 0, 0.5,
                (v) => settings.update3D((s) => s.copyWith(wiggleIntensity: v))),
          ],
        ),

        // Flicker & Pulse
        ui.buildSection(
          id: '3d_flicker',
          title: 'Flicker & Pulse',
          icon: Icons.flash_on,
          color: Colors.orange,
          children: [
            ui.buildEnumPicker<FlickerMode>('Flicker', s.flickerMode, FlickerMode.values,
                (v) => settings.update3D((s) => s.copyWith(flickerMode: v))),
            ui.buildSlider('Flicker Speed', s.flickerSpeed, 0.2, 5,
                (v) => settings.update3D((s) => s.copyWith(flickerSpeed: v))),
            ui.buildSlider('Flicker Amount', s.flickerIntensity, 0, 0.5,
                (v) => settings.update3D((s) => s.copyWith(flickerIntensity: v))),
            Divider(color: ui.theme.divider),
            ui.buildSlider('Pulse Speed', s.pulseSpeed, 0.2, 5,
                (v) => settings.update3D((s) => s.copyWith(pulseSpeed: v))),
            ui.buildSlider('Pulse Amount', s.pulseIntensity, 0, 0.5,
                (v) => settings.update3D((s) => s.copyWith(pulseIntensity: v))),
            ui.buildToggle('Sync Pulse', s.syncPulse,
                (v) => settings.update3D((s) => s.copyWith(syncPulse: v))),
          ],
        ),

        // Bloom
        ui.buildSection(
          id: '3d_bloom',
          title: 'Bloom',
          icon: Icons.flare,
          color: Colors.pink,
          children: [
            ui.buildToggle('Enable', s.enableBloom,
                (v) => settings.update3D((s) => s.copyWith(enableBloom: v))),
            if (s.enableBloom) ...[
              ui.buildSlider('Intensity', s.bloomIntensity, 0.1, 1.5,
                  (v) => settings.update3D((s) => s.copyWith(bloomIntensity: v))),
              ui.buildSlider('Radius', s.bloomRadius, 4, 30,
                  (v) => settings.update3D((s) => s.copyWith(bloomRadius: v))),
            ],
          ],
        ),

        // Particle Colors
        ui.buildSection(
          id: '3d_color',
          title: 'Particle Colors',
          icon: Icons.palette,
          color: Colors.deepOrange,
          children: [
            Text('Core = brightest center, Outer = edge glow',
                style: TextStyle(fontSize: 10, color: ui.theme.textMuted)),
            const SizedBox(height: 8),
            ui.buildColorRow('Core (bright)', s.coreColor,
                () => openColorPicker(s.coreColor)),
            ui.buildColorRow('Mid', s.midColor,
                () => openColorPicker(s.midColor)),
            ui.buildColorRow('Outer (glow)', s.outerColor,
                () => openColorPicker(s.outerColor)),
          ],
        ),

        // Color Palettes
        ui.buildSection(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ui.buildRandomPaletteButton(
          'Random 3D Colors',
          [Colors.orange, Colors.red, Colors.purple],
          _applyRandom3DPalette,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: colorPalettes.map((palette) => 
            ui.buildPaletteTile(palette, () => _apply3DColorPalette(palette.colors))
          ).toList(),
        ),
      ],
    );
  }

  void _apply3DColorPalette(List<Color> colors) {
    if (colors.length >= 3) {
      settings.update3D((s) => s.copyWith(
        coreColor: lightenColor(colors[0], 0.3),
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
      case 0:
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.85).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 30) % 360, 0.7, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 60) % 360, 0.7, 0.5).toColor(),
        ];
        break;
      case 1:
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.85).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 180) % 360, 0.6, 0.5).toColor(),
        ];
        break;
      case 2:
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.85).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 120) % 360, 0.65, 0.6).toColor(),
          HSLColor.fromAHSL(1, (baseHue + 240) % 360, 0.6, 0.5).toColor(),
        ];
        break;
      default:
        colors = [
          HSLColor.fromAHSL(1, baseHue, 0.4, 0.9).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.6, 0.65).toColor(),
          HSLColor.fromAHSL(1, baseHue, 0.7, 0.45).toColor(),
        ];
    }

    _apply3DColorPalette(colors);
  }
}











