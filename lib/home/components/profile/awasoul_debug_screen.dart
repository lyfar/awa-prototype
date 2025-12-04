import 'dart:ui';
import 'package:flutter/material.dart';
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
    return Stack(
      children: [
        // Main sphere using global settings
        const Positioned.fill(
          child: AwaSphere(
            height: double.infinity,
            useGlobalSettings: true,
            interactive: true,
          ),
        ),
        
        // Bloom overlay (handled inside AwaSphere now)
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
          // Light section (most important for "light" effect)
          _buildExpandableSection(
            id: 'light',
            title: 'Light / Emissive',
            icon: Icons.wb_sunny,
            color: Colors.amber,
            children: [
              _buildSlider('Emissive', _settings.emissiveIntensity, 0.5, 3.0, 
                (v) => _settings.emissiveIntensity = v),
              _buildSlider('Core', _settings.coreIntensity, 1.0, 4.0, 
                (v) => _settings.coreIntensity = v),
              _buildSlider('Glow Radius', _settings.glowRadius, 1.0, 6.0, 
                (v) => _settings.glowRadius = v),
              _buildSlider('Glow Soft', _settings.glowSoftness, 2.0, 20.0, 
                (v) => _settings.glowSoftness = v),
              _buildSlider('Halo', _settings.haloOpacity, 0.1, 0.8, 
                (v) => _settings.haloOpacity = v),
              _buildSwitch('Additive Blend', _settings.additiveBlending, 
                (v) => _settings.additiveBlending = v),
            ],
          ),
          
          // Bloom section
          _buildExpandableSection(
            id: 'bloom',
            title: 'Bloom Effect',
            icon: Icons.flare,
            color: Colors.orange,
            children: [
              _buildSwitch('Enable', _settings.enableBloom, 
                (v) => _settings.enableBloom = v),
              if (_settings.enableBloom) ...[
                _buildSlider('Intensity', _settings.bloomIntensity, 0.1, 1.5, 
                  (v) => _settings.bloomIntensity = v),
                _buildSlider('Radius', _settings.bloomRadius, 4.0, 25.0, 
                  (v) => _settings.bloomRadius = v),
              ],
            ],
          ),
          
          // 3D Particles
          _buildExpandableSection(
            id: '3d',
            title: '3D Particles',
            icon: Icons.blur_on,
            color: Colors.blue,
            children: [
              _buildSlider('Count', _settings.particleCount.toDouble(), 100, 600, 
                (v) => _settings.particleCount = v.round()),
              _buildSlider('Size', _settings.particleSize, 1, 8, 
                (v) => _settings.particleSize = v),
            ],
          ),
          
          // 2D Backdrop
          _buildExpandableSection(
            id: '2d',
            title: '2D Backdrop',
            icon: Icons.gradient,
            color: Colors.pink,
            children: [
              _buildSlider('Dots', _settings.backdropDotCount.toDouble(), 100, 600, 
                (v) => _settings.backdropDotCount = v.round()),
              _buildSlider('Dot Size', _settings.backdropDotSize, 2, 12, 
                (v) => _settings.backdropDotSize = v),
              _buildSlider('Opacity', _settings.backdropOpacity, 0.2, 1.0, 
                (v) => _settings.backdropOpacity = v),
              const SizedBox(height: 8),
              _buildColorRow('Center', _settings.gradientStart, (c) => _settings.gradientStart = c),
              _buildColorRow('Middle', _settings.gradientMid, (c) => _settings.gradientMid = c),
              _buildColorRow('Edge', _settings.gradientEnd, (c) => _settings.gradientEnd = c),
            ],
          ),
          
          // Animation
          _buildExpandableSection(
            id: 'anim',
            title: 'Animation',
            icon: Icons.animation,
            color: Colors.green,
            children: [
              _buildSlider('Flicker', _settings.flickerSpeed, 0.2, 3.0, 
                (v) => _settings.flickerSpeed = v),
              _buildSlider('Pulse', _settings.pulseSpeed, 0.2, 3.0, 
                (v) => _settings.pulseSpeed = v),
              _buildSlider('Drift', _settings.driftSpeed, 0.1, 2.0, 
                (v) => _settings.driftSpeed = v),
              _buildSlider('Wobble', _settings.wobbleSpeed, 0.2, 3.0, 
                (v) => _settings.wobbleSpeed = v),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpandableSection({
    required String id,
    required String title,
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
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 10),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
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
  
  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 65, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.orange.shade300,
                inactiveTrackColor: Colors.grey.shade200,
                thumbColor: Colors.orange,
              ),
              child: Slider(value: value, min: min, max: max, onChanged: onChanged),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              value < 10 ? value.toStringAsFixed(1) : value.round().toString(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Spacer(),
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
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: preset,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == preset ? Colors.black54 : Colors.grey.shade300,
                    width: color == preset ? 2 : 1,
                  ),
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
