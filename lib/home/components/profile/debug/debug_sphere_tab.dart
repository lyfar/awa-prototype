import 'package:flutter/material.dart';
import '../../../../soul/awa_soul_settings.dart';
import 'debug_panel_theme.dart';
import 'debug_ui_builders.dart';

/// Global sphere settings tab (background, breathing, presets)
class DebugSphereTab extends StatelessWidget {
  final AwaSoulSettings settings;
  final DebugUIBuilders ui;
  final void Function(Color) openColorPicker;

  const DebugSphereTab({
    super.key,
    required this.settings,
    required this.ui,
    required this.openColorPicker,
  });

  @override
  Widget build(BuildContext context) {
    final s = settings.sphere;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Background
        ui.buildSection(
          id: 'sphere_bg',
          title: 'Background',
          icon: Icons.format_paint,
          color: Colors.deepPurple,
          children: [
            _buildBackgroundPresetPicker(s.backgroundPreset),
            if (s.backgroundPreset == BackgroundPreset.custom) ...[
              const SizedBox(height: 8),
              ui.buildColorRow('Custom', s.customBackgroundColor,
                  () => openColorPicker(s.customBackgroundColor)),
            ],
          ],
        ),

        // Breathing
        ui.buildSection(
          id: 'sphere_breath',
          title: 'Breathing',
          icon: Icons.air,
          color: Colors.teal,
          children: [
            ui.buildSlider('Speed', s.breathingSpeed, 0.1, 1,
                (v) => settings.updateSphere((s) => s.copyWith(breathingSpeed: v))),
            ui.buildSlider('Intensity', s.breathingIntensity, 0, 3,
                (v) => settings.updateSphere((s) => s.copyWith(breathingIntensity: v))),
            ui.buildSlider('Base Scale', s.baseScale, 0.5, 1.5,
                (v) => settings.updateSphere((s) => s.copyWith(baseScale: v))),
          ],
        ),

        // Quick Presets
        ui.buildSection(
          id: 'sphere_presets',
          title: 'Quick Presets',
          icon: Icons.auto_awesome,
          color: Colors.amber,
          children: _buildPresetList(),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBackgroundPresetPicker(BackgroundPreset selected) {
    final t = ui.theme;
    final presets = [
      (BackgroundPreset.black, 'Black', const Color(0xFF000000)),
      (BackgroundPreset.white, 'White', const Color(0xFFFFFFFF)),
      (BackgroundPreset.midnight, 'Midnight', const Color(0xFF0D1117)),
      (BackgroundPreset.warmDark, 'Warm', const Color(0xFF1A1410)),
      (BackgroundPreset.coolGray, 'Gray', const Color(0xFF1C1C1E)),
      (BackgroundPreset.forest, 'Forest', const Color(0xFF0D1A14)),
      (BackgroundPreset.wine, 'Wine', const Color(0xFF1A0D12)),
      (BackgroundPreset.ocean, 'Ocean', const Color(0xFF0A1520)),
      (BackgroundPreset.custom, 'Custom', settings.sphere.customBackgroundColor),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) {
        final (type, name, color) = preset;
        final isSelected = selected == type;
        final presetLuminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
        final needsDarkBorder = presetLuminance > 0.5;

        return GestureDetector(
          onTap: () => settings.updateSphere((s) => s.copyWith(backgroundPreset: type)),
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
                    ? Icon(Icons.colorize, size: 16, color: getContrastColor(color))
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

  List<Widget> _buildPresetList() {
    return [
      ui.buildPresetTile('Calm', 'Gentle, soft glow', _applyCalm),
      ui.buildPresetTile('Energetic', 'Bright, lively motion', _applyEnergetic),
      ui.buildPresetTile('Meditation', 'Slow, rhythmic pulse', _applyMeditation),
      ui.buildPresetTile('Fire', 'Candle-like flicker', _applyFire),
      ui.buildPresetTile('Ocean Dream', 'Cool, flowing waves', _applyOcean),
      ui.buildPresetTile('Pure Light', 'Clean white canvas', _applyPureLight),
      ui.buildPresetTile('Intense Sunset', '12-tone sunset spectrum', _applyIntenseSunset),
      ui.buildPresetTile('Sunset Warm', 'Fire and coral tones', _applySunsetWarm),
      ui.buildPresetTile('Sunset Cool', 'Purple afterglow', _applySunsetCool),
    ];
  }

  void _applyCalm() {
    settings.layer3D = Layer3DSettings(
      flickerMode: FlickerMode.gentle,
      flickerSpeed: 1.5,
      pulseSpeed: 1.5,
      emissiveIntensity: 2.0,
      wiggleStyle: WiggleStyle.subtle,
    );
    settings.layer2D = Layer2DSettings(
      blinkMode: FlickerMode.gentle,
      blinkSpeed: 0.4,
      opacity: 0.4,
    );
    settings.sphere = SphereSettings(
      breathingIntensity: 1.2,
      backgroundPreset: BackgroundPreset.black,
    );
  }

  void _applyEnergetic() {
    settings.layer3D = Layer3DSettings(
      flickerMode: FlickerMode.sparkle,
      flickerSpeed: 3.5,
      pulseSpeed: 3.5,
      emissiveIntensity: 4.0,
      wiggleStyle: WiggleStyle.electric,
      driftSpeed: 2.0,
    );
    settings.layer2D = Layer2DSettings(
      blinkMode: FlickerMode.sparkle,
      blinkSpeed: 1.5,
      opacity: 0.7,
    );
    settings.sphere = SphereSettings(
      breathingIntensity: 2.5,
      backgroundPreset: BackgroundPreset.midnight,
    );
  }

  void _applyMeditation() {
    settings.layer3D = Layer3DSettings(
      flickerMode: FlickerMode.off,
      pulseSpeed: 0.8,
      pulseIntensity: 0.2,
      syncPulse: true,
      emissiveIntensity: 2.5,
      wiggleStyle: WiggleStyle.none,
    );
    settings.layer2D = Layer2DSettings(
      blinkMode: FlickerMode.off,
      blinkSpeed: 0.3,
      syncBlink: true,
    );
    settings.sphere = SphereSettings(
      breathingIntensity: 2.0,
      breathingSpeed: 0.2,
      backgroundPreset: BackgroundPreset.black,
    );
  }

  void _applyFire() {
    settings.layer3D = Layer3DSettings(
      flickerMode: FlickerMode.candle,
      flickerSpeed: 4.0,
      flickerIntensity: 0.3,
      emissiveIntensity: 3.5,
      coreColor: const Color(0xFFFFFAE0),
      midColor: const Color(0xFFFFB040),
      outerColor: const Color(0xFFE85020),
    );
    settings.layer2D = Layer2DSettings(
      gradientStart: const Color(0xFFFFD080),
      gradientMid: const Color(0xFFFF8040),
      gradientEnd: const Color(0xFFCC4020),
      blinkMode: FlickerMode.candle,
    );
    settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.warmDark);
  }

  void _applyOcean() {
    settings.layer3D = Layer3DSettings(
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
    settings.layer2D = Layer2DSettings(
      gradientStart: const Color(0xFF80D0F0),
      gradientMid: const Color(0xFF4090C0),
      gradientEnd: const Color(0xFF206080),
      blinkMode: FlickerMode.wave,
    );
    settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.ocean);
  }

  void _applyPureLight() {
    settings.layer3D = Layer3DSettings(
      flickerMode: FlickerMode.gentle,
      flickerSpeed: 1.0,
      emissiveIntensity: 1.5,
      coreColor: const Color(0xFFFFEEDD),
      midColor: const Color(0xFFFFCCBB),
      outerColor: const Color(0xFFDDA0A0),
    );
    settings.layer2D = Layer2DSettings(
      gradientStart: const Color(0xFFFFD4C4),
      gradientMid: const Color(0xFFFFB8A8),
      gradientEnd: const Color(0xFFE8A090),
      opacity: 0.3,
    );
    settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.white);
  }

  void _applyIntenseSunset() {
    settings.layer3D = Layer3DSettings(
      flickerMode: FlickerMode.candle,
      flickerSpeed: 2.5,
      flickerIntensity: 0.25,
      emissiveIntensity: 3.5,
      coreColor: const Color(0xFFFF6A14),
      midColor: const Color(0xFFF91A4D),
      outerColor: const Color(0xFF6A05B9),
      motionPattern: MotionPattern.organic,
      wiggleStyle: WiggleStyle.fluid,
      driftSpeed: 1.2,
    );
    settings.layer2D = Layer2DSettings(
      gradientStart: const Color(0xFFFF541F),
      gradientMid: const Color(0xFFDD0F6F),
      gradientEnd: const Color(0xFF8807A8),
      blinkMode: FlickerMode.wave,
      blinkSpeed: 0.8,
      opacity: 0.65,
    );
    settings.sphere = SphereSettings(
      backgroundPreset: BackgroundPreset.black,
      breathingIntensity: 1.5,
    );
  }

  void _applySunsetWarm() {
    settings.layer3D = Layer3DSettings(
      flickerMode: FlickerMode.candle,
      flickerSpeed: 3.0,
      emissiveIntensity: 3.0,
      coreColor: const Color(0xFFFFFFE0),
      midColor: const Color(0xFFFF6A14),
      outerColor: const Color(0xFFFF263D),
    );
    settings.layer2D = Layer2DSettings(
      gradientStart: const Color(0xFFFF6A14),
      gradientMid: const Color(0xFFFF3533),
      gradientEnd: const Color(0xFFEB125F),
      blinkMode: FlickerMode.candle,
    );
    settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.warmDark);
  }

  void _applySunsetCool() {
    settings.layer3D = Layer3DSettings(
      flickerMode: FlickerMode.gentle,
      flickerSpeed: 1.5,
      emissiveIntensity: 2.5,
      coreColor: const Color(0xFFEB125F),
      midColor: const Color(0xFFA40A97),
      outerColor: const Color(0xFF6A05B9),
      motionPattern: MotionPattern.breathe,
    );
    settings.layer2D = Layer2DSettings(
      gradientStart: const Color(0xFFDD0F6F),
      gradientMid: const Color(0xFFA40A97),
      gradientEnd: const Color(0xFF6A05B9),
      blinkMode: FlickerMode.gentle,
      blinkSpeed: 0.5,
    );
    settings.sphere = SphereSettings(backgroundPreset: BackgroundPreset.midnight);
  }
}











