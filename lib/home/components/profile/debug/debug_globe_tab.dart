import 'package:flutter/material.dart';
import '../../../../soul/awa_soul_settings.dart';
import 'debug_ui_builders.dart';

/// Settings class for globe debug controls - focused on layer blending
class GlobeDebugSettings extends ChangeNotifier {
  static final GlobeDebugSettings _instance = GlobeDebugSettings._internal();
  factory GlobeDebugSettings() => _instance;
  GlobeDebugSettings._internal();

  // === GLOBE BASE LAYER ===
  bool _showGlobe = true;
  bool get showGlobe => _showGlobe;
  set showGlobe(bool v) {
    _showGlobe = v;
    notifyListeners();
  }

  bool _showEarthTexture = true;
  bool get showEarthTexture => _showEarthTexture;
  set showEarthTexture(bool v) {
    _showEarthTexture = v;
    notifyListeners();
  }

  bool _showAtmosphere = true;
  bool get showAtmosphere => _showAtmosphere;
  set showAtmosphere(bool v) {
    _showAtmosphere = v;
    notifyListeners();
  }

  double _earthOpacity = 1.0;
  double get earthOpacity => _earthOpacity;
  set earthOpacity(double v) {
    _earthOpacity = v;
    notifyListeners();
  }

  // === GLOBE PARTICLES ===
  bool _showCommunityLights = true;
  bool get showCommunityLights => _showCommunityLights;
  set showCommunityLights(bool v) {
    _showCommunityLights = v;
    notifyListeners();
  }

  bool _showUserLight = true;
  bool get showUserLight => _showUserLight;
  set showUserLight(bool v) {
    _showUserLight = v;
    notifyListeners();
  }

  // User location
  double _userLatitude = 37.7749;
  double get userLatitude => _userLatitude;
  set userLatitude(double v) {
    _userLatitude = v;
    notifyListeners();
  }

  double _userLongitude = -122.4194;
  double get userLongitude => _userLongitude;
  set userLongitude(double v) {
    _userLongitude = v;
    notifyListeners();
  }

  // === BLENDING ===
  double _particleOverlayOpacity = 1.0;
  double get particleOverlayOpacity => _particleOverlayOpacity;
  set particleOverlayOpacity(double v) {
    _particleOverlayOpacity = v;
    notifyListeners();
  }

  /// Reset to defaults
  void resetToDefaults() {
    _showGlobe = true;
    _showEarthTexture = true;
    _showAtmosphere = true;
    _earthOpacity = 1.0;
    _showCommunityLights = true;
    _showUserLight = true;
    _userLatitude = 37.7749;
    _userLongitude = -122.4194;
    _particleOverlayOpacity = 1.0;
    notifyListeners();
  }
}

/// Globe layer blending tab - combine globe with AwaSoul layers
class DebugGlobeTab extends StatelessWidget {
  final GlobeDebugSettings settings;
  final AwaSoulSettings soulSettings;
  final DebugUIBuilders ui;

  const DebugGlobeTab({
    super.key,
    required this.settings,
    required this.soulSettings,
    required this.ui,
  });

  @override
  Widget build(BuildContext context) {
    print('DebugGlobeTab: Building layer controls');

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Quick info
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.layers, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Blend globe with AwaSoul particle layers',
                  style: TextStyle(
                    fontSize: 12,
                    color: ui.theme.text,
                  ),
                ),
              ),
            ],
          ),
        ),

        // === AWASOUL OVERLAY LAYERS ===
        ui.buildSection(
          id: 'overlay_layers',
          title: 'AwaSoul Particle Layers',
          icon: Icons.blur_on,
          color: Colors.deepOrange,
          children: [
            ui.buildLayerToggle(
              '3D Particles (Sphere)',
              Icons.blur_on,
              soulSettings.layer3D.enabled,
              (v) => soulSettings.update3D((s) => s.copyWith(enabled: v)),
            ),
            ui.buildLayerToggle(
              '2D Backdrop (Spiral)',
              Icons.gradient,
              soulSettings.layer2D.enabled,
              (v) => soulSettings.update2D((s) => s.copyWith(enabled: v)),
            ),
            const SizedBox(height: 8),
            ui.buildSlider(
              'Overlay Opacity',
              settings.particleOverlayOpacity,
              0,
              1,
              (v) => settings.particleOverlayOpacity = v,
            ),
          ],
        ),

        // === GLOBE BASE ===
        ui.buildSection(
          id: 'globe_base',
          title: 'Globe Base Layer',
          icon: Icons.public,
          color: Colors.blue,
          children: [
            ui.buildLayerToggle(
              'Show Globe',
              Icons.public,
              settings.showGlobe,
              (v) => settings.showGlobe = v,
            ),
            if (settings.showGlobe) ...[
              ui.buildToggle(
                'Earth Texture',
                settings.showEarthTexture,
                (v) => settings.showEarthTexture = v,
              ),
              ui.buildToggle(
                'Atmosphere Glow',
                settings.showAtmosphere,
                (v) => settings.showAtmosphere = v,
              ),
              ui.buildSlider(
                'Earth Opacity',
                settings.earthOpacity,
                0,
                1,
                (v) => settings.earthOpacity = v,
              ),
            ],
          ],
        ),

        // === GLOBE LIGHTS ===
        ui.buildSection(
          id: 'globe_lights',
          title: 'Globe Lights',
          icon: Icons.lightbulb,
          color: Colors.amber,
          children: [
            ui.buildToggle(
              'Community Lights',
              settings.showCommunityLights,
              (v) => settings.showCommunityLights = v,
            ),
            ui.buildToggle(
              'User Light',
              settings.showUserLight,
              (v) => settings.showUserLight = v,
            ),
            if (settings.showUserLight) ...[
              const SizedBox(height: 8),
              ui.buildSlider(
                'Latitude',
                settings.userLatitude,
                -90,
                90,
                (v) => settings.userLatitude = v,
              ),
              ui.buildSlider(
                'Longitude',
                settings.userLongitude,
                -180,
                180,
                (v) => settings.userLongitude = v,
              ),
              const SizedBox(height: 8),
              _buildLocationPresets(),
            ],
          ],
        ),

        // === QUICK PRESETS ===
        ui.buildSection(
          id: 'presets',
          title: 'Quick Presets',
          icon: Icons.auto_awesome,
          color: Colors.purple,
          children: [
            _buildPresetButtons(),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLocationPresets() {
    final t = ui.theme;
    final locations = [
      ('SF', 37.7749, -122.4194),
      ('NYC', 40.7128, -74.0060),
      ('London', 51.5074, -0.1278),
      ('Tokyo', 35.6762, 139.6503),
      ('Sydney', -33.8688, 151.2093),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: locations.map((loc) {
        return GestureDetector(
          onTap: () {
            settings.userLatitude = loc.$2;
            settings.userLongitude = loc.$3;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.border),
            ),
            child: Text(
              loc.$1,
              style: TextStyle(fontSize: 11, color: t.textSecondary),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPresetButtons() {
    final t = ui.theme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quickly configure layer combinations',
          style: TextStyle(fontSize: 10, color: t.textMuted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _presetButton('Globe Only', Colors.blue, () {
              settings.showGlobe = true;
              settings.showEarthTexture = true;
              soulSettings.update3D((s) => s.copyWith(enabled: false));
              soulSettings.update2D((s) => s.copyWith(enabled: false));
            }),
            _presetButton('Soul Only', Colors.orange, () {
              settings.showGlobe = false;
              soulSettings.update3D((s) => s.copyWith(enabled: true));
              soulSettings.update2D((s) => s.copyWith(enabled: true));
            }),
            _presetButton('All Layers', Colors.purple, () {
              settings.showGlobe = true;
              settings.showEarthTexture = true;
              settings.particleOverlayOpacity = 1.0;
              soulSettings.update3D((s) => s.copyWith(enabled: true));
              soulSettings.update2D((s) => s.copyWith(enabled: true));
            }),
            _presetButton('Globe + 3D', Colors.teal, () {
              settings.showGlobe = true;
              settings.showEarthTexture = true;
              soulSettings.update3D((s) => s.copyWith(enabled: true));
              soulSettings.update2D((s) => s.copyWith(enabled: false));
            }),
            _presetButton('Globe + 2D', Colors.green, () {
              settings.showGlobe = true;
              settings.showEarthTexture = true;
              soulSettings.update3D((s) => s.copyWith(enabled: false));
              soulSettings.update2D((s) => s.copyWith(enabled: true));
            }),
            _presetButton('Subtle Blend', Colors.indigo, () {
              settings.showGlobe = true;
              settings.showEarthTexture = true;
              settings.earthOpacity = 0.7;
              settings.particleOverlayOpacity = 0.5;
              soulSettings.update3D((s) => s.copyWith(enabled: true));
              soulSettings.update2D((s) => s.copyWith(enabled: true));
            }),
          ],
        ),
      ],
    );
  }

  Widget _presetButton(String label, Color color, VoidCallback onTap) {
    final t = ui.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: t.text,
          ),
        ),
      ),
    );
  }
}
