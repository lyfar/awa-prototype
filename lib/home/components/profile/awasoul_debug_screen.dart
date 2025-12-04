import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../soul/awa_sphere.dart';
import '../../../soul/awa_soul_settings.dart';

/// Full-screen AwaSoul debug page - changes apply globally!
class AwaSoulDebugScreen extends StatefulWidget {
  const AwaSoulDebugScreen({super.key});

  @override
  State<AwaSoulDebugScreen> createState() => _AwaSoulDebugScreenState();
}

class _AwaSoulDebugScreenState extends State<AwaSoulDebugScreen> {
  final _settings = AwaSoulSettings();
  String? _expandedSection;

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
    setState(() {});
  }
  
  void _copySettings() {
    final export = '''
AwaSoul Settings Export
=======================
// Light / Emissive
emissiveIntensity: ${_settings.emissiveIntensity.toStringAsFixed(2)}
coreIntensity: ${_settings.coreIntensity.toStringAsFixed(2)}
glowRadius: ${_settings.glowRadius.toStringAsFixed(2)}
glowSoftness: ${_settings.glowSoftness.toStringAsFixed(2)}
haloOpacity: ${_settings.haloOpacity.toStringAsFixed(2)}
additiveBlending: ${_settings.additiveBlending}

// Bloom
enableBloom: ${_settings.enableBloom}
bloomIntensity: ${_settings.bloomIntensity.toStringAsFixed(2)}
bloomRadius: ${_settings.bloomRadius.toStringAsFixed(2)}

// 3D Particles
particleCount: ${_settings.particleCount}
particleSize: ${_settings.particleSize.toStringAsFixed(2)}

// 2D Backdrop
backdropDotCount: ${_settings.backdropDotCount}
backdropDotSize: ${_settings.backdropDotSize.toStringAsFixed(2)}
backdropOpacity: ${_settings.backdropOpacity.toStringAsFixed(2)}
gradientStart: 0x${_settings.gradientStart.value.toRadixString(16).toUpperCase()}
gradientMid: 0x${_settings.gradientMid.value.toRadixString(16).toUpperCase()}
gradientEnd: 0x${_settings.gradientEnd.value.toRadixString(16).toUpperCase()}

// Animation Speeds
breathingIntensity: ${_settings.breathingIntensity.toStringAsFixed(2)}
flickerSpeed: ${_settings.flickerSpeed.toStringAsFixed(2)}
pulseSpeed: ${_settings.pulseSpeed.toStringAsFixed(2)}
driftSpeed: ${_settings.driftSpeed.toStringAsFixed(2)}
wobbleSpeed: ${_settings.wobbleSpeed.toStringAsFixed(2)}
''';
    
    Clipboard.setData(ClipboardData(text: export));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            
            // === SPHERE PREVIEW (55%) ===
            Expanded(
              flex: 55,
              child: _buildSpherePreview(),
            ),
            
            // === CONTROLS (45%) ===
            Expanded(
              flex: 45,
              child: _buildControls(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AwaSoul Debug',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Changes apply globally',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Copy button
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.black54, size: 20),
            onPressed: _copySettings,
            tooltip: 'Copy settings',
          ),
          // Reset button
          TextButton(
            onPressed: () {
              _settings.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset to defaults'), duration: Duration(seconds: 1)),
              );
            },
            child: const Text('Reset', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpherePreview() {
    // Force rebuild with key when settings change
    return Stack(
      key: ValueKey('sphere_${_settings.flickerSpeed}_${_settings.pulseSpeed}_${_settings.driftSpeed}'),
      children: [
        Positioned.fill(
          child: AwaSphere(
            height: double.infinity,
            useGlobalSettings: true,
            interactive: true,
          ),
        ),
      ],
    );
  }
  
  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Light section
          _buildExpandableSection(
            id: 'light',
            title: 'Light / Emissive',
            subtitle: 'HDR brightness & glow',
            icon: Icons.wb_sunny,
            color: Colors.amber,
            children: [
              _buildSlider('Emissive Intensity', 'HDR brightness multiplier', 
                _settings.emissiveIntensity, 0.5, 3.0, 
                (v) => _settings.emissiveIntensity = v),
              _buildSlider('Core Intensity', 'Particle center brightness', 
                _settings.coreIntensity, 1.0, 4.0, 
                (v) => _settings.coreIntensity = v),
              _buildSlider('Glow Radius', 'Size of light spread', 
                _settings.glowRadius, 1.0, 6.0, 
                (v) => _settings.glowRadius = v),
              _buildSlider('Glow Softness', 'Blur amount for glow', 
                _settings.glowSoftness, 2.0, 20.0, 
                (v) => _settings.glowSoftness = v),
              _buildSlider('Halo Opacity', 'Outer glow visibility', 
                _settings.haloOpacity, 0.1, 0.8, 
                (v) => _settings.haloOpacity = v),
              _buildSwitch('Additive Blending', 'Simulate light addition', 
                _settings.additiveBlending, 
                (v) => _settings.additiveBlending = v),
            ],
          ),
          
          // Bloom section
          _buildExpandableSection(
            id: 'bloom',
            title: 'Bloom Effect',
            subtitle: 'Post-process light bleed',
            icon: Icons.flare,
            color: Colors.orange,
            children: [
              _buildSwitch('Enable Bloom', 'Apply bloom filter', 
                _settings.enableBloom, 
                (v) => _settings.enableBloom = v),
              if (_settings.enableBloom) ...[
                _buildSlider('Bloom Intensity', 'Strength of light bleed', 
                  _settings.bloomIntensity, 0.1, 1.5, 
                  (v) => _settings.bloomIntensity = v),
                _buildSlider('Bloom Radius', 'Size of bloom blur', 
                  _settings.bloomRadius, 4.0, 25.0, 
                  (v) => _settings.bloomRadius = v),
              ],
            ],
          ),
          
          // Animation section
          _buildExpandableSection(
            id: 'anim',
            title: 'Animation',
            subtitle: 'Movement & twinkle speeds',
            icon: Icons.animation,
            color: Colors.purple,
            children: [
              _buildSlider('Breathing', 'Sphere scale pulsing intensity', 
                _settings.breathingIntensity, 0.0, 2.0, 
                (v) => _settings.breathingIntensity = v),
              _buildSlider('Flicker Speed', 'Twinkle rate of particles', 
                _settings.flickerSpeed, 0.2, 3.0, 
                (v) => _settings.flickerSpeed = v),
              _buildSlider('Pulse Speed', 'Particle brightness rhythm', 
                _settings.pulseSpeed, 0.2, 3.0, 
                (v) => _settings.pulseSpeed = v),
              _buildSlider('Drift Speed', 'Floating movement rate', 
                _settings.driftSpeed, 0.1, 2.0, 
                (v) => _settings.driftSpeed = v),
              _buildSlider('Wobble Speed', 'Shape distortion rate', 
                _settings.wobbleSpeed, 0.2, 3.0, 
                (v) => _settings.wobbleSpeed = v),
            ],
          ),
          
          // 3D Particles
          _buildExpandableSection(
            id: '3d',
            title: '3D Particles',
            subtitle: 'Front layer light points',
            icon: Icons.blur_on,
            color: Colors.blue,
            children: [
              _buildSlider('Particle Count', 'Number of light points', 
                _settings.particleCount.toDouble(), 100, 600, 
                (v) => _settings.particleCount = v.round()),
              _buildSlider('Particle Size', 'Base size of each point', 
                _settings.particleSize, 1, 8, 
                (v) => _settings.particleSize = v),
            ],
          ),
          
          // 2D Backdrop
          _buildExpandableSection(
            id: '2d',
            title: '2D Backdrop',
            subtitle: 'Background spiral pattern',
            icon: Icons.gradient,
            color: Colors.pink,
            children: [
              _buildSlider('Dot Count', 'Number of backdrop dots', 
                _settings.backdropDotCount.toDouble(), 100, 600, 
                (v) => _settings.backdropDotCount = v.round()),
              _buildSlider('Dot Size', 'Size of backdrop dots', 
                _settings.backdropDotSize, 2, 12, 
                (v) => _settings.backdropDotSize = v),
              _buildSlider('Opacity', 'Backdrop visibility', 
                _settings.backdropOpacity, 0.2, 1.0, 
                (v) => _settings.backdropOpacity = v),
              const SizedBox(height: 8),
              const Text('Gradient Colors', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              _buildColorRow('Center', _settings.gradientStart, (c) => _settings.gradientStart = c),
              _buildColorRow('Middle', _settings.gradientMid, (c) => _settings.gradientMid = c),
              _buildColorRow('Edge', _settings.gradientEnd, (c) => _settings.gradientEnd = c),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpandableSection({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final isExpanded = _expandedSection == id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isExpanded ? color.withOpacity(0.5) : Colors.grey.shade200),
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey, size: 20),
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
  
  Widget _buildSlider(String label, String hint, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text(hint, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value < 10 ? value.toStringAsFixed(2) : value.round().toString(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.orange,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.orange,
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitch(String label, String hint, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(hint, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.orange),
        ],
      ),
    );
  }
  
  Widget _buildColorRow(String label, Color color, ValueChanged<Color> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
          const SizedBox(width: 8),
          ..._colorPresets.map((preset) => Padding(
            padding: const EdgeInsets.only(right: 5),
            child: GestureDetector(
              onTap: () => onChanged(preset),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: preset,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == preset ? Colors.black : Colors.grey.shade300,
                    width: color == preset ? 2.5 : 1,
                  ),
                  boxShadow: color == preset ? [
                    BoxShadow(color: preset.withOpacity(0.5), blurRadius: 4),
                  ] : null,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
  
  static const List<Color> _colorPresets = [
    Color(0xFFE8C8B8),
    Color(0xFFFFF0E0),
    Color(0xFFFFD4A8),
    Color(0xFFFFB07C),
    Color(0xFFE8967C),
    Color(0xFFD8A0A8),
    Color(0xFFEFABBF),
    Color(0xFFB89FC1),
  ];
}
