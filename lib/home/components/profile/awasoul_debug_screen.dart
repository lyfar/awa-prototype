import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../soul/awa_sphere.dart';

/// Full-screen AwaSoul debug page for tweaking all visual parameters
class AwaSoulDebugScreen extends StatefulWidget {
  const AwaSoulDebugScreen({super.key});

  @override
  State<AwaSoulDebugScreen> createState() => _AwaSoulDebugScreenState();
}

class _AwaSoulDebugScreenState extends State<AwaSoulDebugScreen> {
  // === 3D PARTICLE SETTINGS ===
  int _particleCount = 450;
  double _particleSize = 3.0;
  double _energy = 0.0;
  
  // === ANIMATION SPEEDS ===
  double _flickerSpeed = 1.8;
  double _pulseSpeed = 0.8;
  double _driftSpeed = 0.3;
  double _wobbleSpeed = 1.2;
  
  // === COLORS ===
  double _warmth = 0.5; // 0 = cool lavender, 1 = hot white
  double _saturation = 0.7;
  
  // === 2D BACKDROP SETTINGS ===
  int _backdropDotCount = 380;
  double _backdropRadius = 1.08;
  double _backdropBlinkSpeed = 0.6;
  double _backdropOpacity = 0.7;
  
  // === BLOOM / FILTER SETTINGS ===
  double _bloomIntensity = 1.0;
  double _bloomRadius = 5.0;
  double _glowBlur = 12.0;
  bool _enableBloom = true;
  
  // === SPHERE SETTINGS ===
  double _sphereScale = 1.0;
  bool _interactive = true;
  
  // Computed colors based on warmth
  Color get _primaryColor {
    return Color.lerp(
      const Color(0xFFD8A0A8), // Cool rose
      const Color(0xFFFFB07C), // Warm orange
      _warmth,
    )!.withOpacity(_saturation);
  }
  
  Color get _secondaryColor {
    return Color.lerp(
      const Color(0xFFE8C8D0), // Cool pink
      const Color(0xFFFFE4B5), // Warm yellow
      _warmth,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AwaSoul Debug',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: Column(
        children: [
          // === AWASOUL SPHERE ===
          _buildSphereSection(),
          
          // === CONTROLS ===
          Expanded(
            child: _buildControlsPanel(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSphereSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final sphereHeight = screenHeight * 0.35;
    
    return Stack(
      children: [
        // Sphere with optional bloom filter
        if (_enableBloom)
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _glowBlur * 0.3 * _bloomIntensity,
                sigmaY: _glowBlur * 0.3 * _bloomIntensity,
              ),
              child: _buildSphere(sphereHeight),
            ),
          )
        else
          _buildSphere(sphereHeight),
        
        // Layered bloom effect
        if (_enableBloom)
          Positioned.fill(
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: _glowBlur * _bloomIntensity,
                  sigmaY: _glowBlur * _bloomIntensity,
                ),
                child: Opacity(
                  opacity: 0.3 * _bloomIntensity,
                  child: _buildSphere(sphereHeight),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildSphere(double height) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Center(
        child: Transform.scale(
          scale: _sphereScale,
          child: AwaSphere(
            height: height * 0.9,
            particleCount: _particleCount,
            particleSize: _particleSize,
            energy: _energy,
            primaryColor: _primaryColor,
            secondaryColor: _secondaryColor,
            interactive: _interactive,
          ),
        ),
      ),
    );
  }
  
  Widget _buildControlsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black45,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: '3D'),
                  Tab(text: '2D'),
                  Tab(text: 'Bloom'),
                  Tab(text: 'Anim'),
                ],
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  _build3DSettings(),
                  _build2DSettings(),
                  _buildBloomSettings(),
                  _buildAnimationSettings(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _build3DSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle('3D Particles'),
        _buildSlider(
          label: 'Particle Count',
          value: _particleCount.toDouble(),
          min: 100,
          max: 800,
          divisions: 70,
          valueLabel: '$_particleCount',
          onChanged: (v) => setState(() => _particleCount = v.round()),
        ),
        _buildSlider(
          label: 'Particle Size',
          value: _particleSize,
          min: 1.0,
          max: 8.0,
          valueLabel: _particleSize.toStringAsFixed(1),
          onChanged: (v) => setState(() => _particleSize = v),
        ),
        _buildSlider(
          label: 'Energy',
          value: _energy,
          min: 0.0,
          max: 1.0,
          valueLabel: (_energy * 100).toStringAsFixed(0) + '%',
          onChanged: (v) => setState(() => _energy = v),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Colors'),
        _buildSlider(
          label: 'Warmth',
          value: _warmth,
          min: 0.0,
          max: 1.0,
          valueLabel: _warmth < 0.3 ? 'Cool' : _warmth > 0.7 ? 'Hot' : 'Warm',
          onChanged: (v) => setState(() => _warmth = v),
        ),
        _buildSlider(
          label: 'Saturation',
          value: _saturation,
          min: 0.3,
          max: 1.0,
          valueLabel: (_saturation * 100).toStringAsFixed(0) + '%',
          onChanged: (v) => setState(() => _saturation = v),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Sphere'),
        _buildSlider(
          label: 'Scale',
          value: _sphereScale,
          min: 0.5,
          max: 1.5,
          valueLabel: '${(_sphereScale * 100).toStringAsFixed(0)}%',
          onChanged: (v) => setState(() => _sphereScale = v),
        ),
        _buildSwitch(
          label: 'Interactive (drag/pinch)',
          value: _interactive,
          onChanged: (v) => setState(() => _interactive = v),
        ),
      ],
    );
  }
  
  Widget _build2DSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle('2D Backdrop Spiral'),
        _buildSlider(
          label: 'Dot Count',
          value: _backdropDotCount.toDouble(),
          min: 100,
          max: 600,
          divisions: 50,
          valueLabel: '$_backdropDotCount',
          onChanged: (v) => setState(() => _backdropDotCount = v.round()),
        ),
        _buildSlider(
          label: 'Radius Multiplier',
          value: _backdropRadius,
          min: 0.8,
          max: 1.5,
          valueLabel: '${_backdropRadius.toStringAsFixed(2)}x',
          onChanged: (v) => setState(() => _backdropRadius = v),
        ),
        _buildSlider(
          label: 'Opacity',
          value: _backdropOpacity,
          min: 0.2,
          max: 1.0,
          valueLabel: '${(_backdropOpacity * 100).toStringAsFixed(0)}%',
          onChanged: (v) => setState(() => _backdropOpacity = v),
        ),
        _buildSlider(
          label: 'Blink Speed',
          value: _backdropBlinkSpeed,
          min: 0.1,
          max: 2.0,
          valueLabel: '${_backdropBlinkSpeed.toStringAsFixed(1)}x',
          onChanged: (v) => setState(() => _backdropBlinkSpeed = v),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          'The 2D backdrop creates the warm gradient spiral behind the 3D particles. '
          'Adjust these to change how prominent or subtle it appears.',
        ),
      ],
    );
  }
  
  Widget _buildBloomSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle('Bloom Filter'),
        _buildSwitch(
          label: 'Enable Bloom',
          value: _enableBloom,
          onChanged: (v) => setState(() => _enableBloom = v),
        ),
        const SizedBox(height: 8),
        if (_enableBloom) ...[
          _buildSlider(
            label: 'Bloom Intensity',
            value: _bloomIntensity,
            min: 0.1,
            max: 2.0,
            valueLabel: '${(_bloomIntensity * 100).toStringAsFixed(0)}%',
            onChanged: (v) => setState(() => _bloomIntensity = v),
          ),
          _buildSlider(
            label: 'Blur Radius',
            value: _glowBlur,
            min: 2.0,
            max: 30.0,
            valueLabel: '${_glowBlur.toStringAsFixed(0)}px',
            onChanged: (v) => setState(() => _glowBlur = v),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            'Bloom creates a light bleed effect that makes bright areas glow. '
            'Higher intensity = more glow spreading outward. '
            'This simulates real camera lens effects when capturing bright lights.',
          ),
        ] else
          _buildInfoCard(
            'Enable bloom to add a glowing light bleed effect to the particles, '
            'simulating how cameras capture bright point lights.',
          ),
      ],
    );
  }
  
  Widget _buildAnimationSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle('Animation Speeds'),
        _buildSlider(
          label: 'Flicker Speed',
          value: _flickerSpeed,
          min: 0.5,
          max: 5.0,
          valueLabel: '${_flickerSpeed.toStringAsFixed(1)}x',
          onChanged: (v) => setState(() => _flickerSpeed = v),
        ),
        _buildSlider(
          label: 'Pulse Speed',
          value: _pulseSpeed,
          min: 0.2,
          max: 3.0,
          valueLabel: '${_pulseSpeed.toStringAsFixed(1)}x',
          onChanged: (v) => setState(() => _pulseSpeed = v),
        ),
        _buildSlider(
          label: 'Drift Speed',
          value: _driftSpeed,
          min: 0.05,
          max: 1.0,
          valueLabel: '${_driftSpeed.toStringAsFixed(2)}x',
          onChanged: (v) => setState(() => _driftSpeed = v),
        ),
        _buildSlider(
          label: 'Wobble Speed',
          value: _wobbleSpeed,
          min: 0.3,
          max: 3.0,
          valueLabel: '${_wobbleSpeed.toStringAsFixed(1)}x',
          onChanged: (v) => setState(() => _wobbleSpeed = v),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          'Flicker: How fast particles twinkle\n'
          'Pulse: Slow breathing rhythm\n'
          'Drift: Gentle floating movement\n'
          'Wobble: Organic shape distortion',
        ),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
  
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String valueLabel,
    required ValueChanged<double> onChanged,
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valueLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFFB07C),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color(0xFFFF9060),
              overlayColor: const Color(0xFFFF9060).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF9060),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFE4D4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: Colors.orange.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _resetToDefaults() {
    setState(() {
      _particleCount = 450;
      _particleSize = 3.0;
      _energy = 0.0;
      _flickerSpeed = 1.8;
      _pulseSpeed = 0.8;
      _driftSpeed = 0.3;
      _wobbleSpeed = 1.2;
      _warmth = 0.5;
      _saturation = 0.7;
      _backdropDotCount = 380;
      _backdropRadius = 1.08;
      _backdropBlinkSpeed = 0.6;
      _backdropOpacity = 0.7;
      _bloomIntensity = 1.0;
      _bloomRadius = 5.0;
      _glowBlur = 12.0;
      _enableBloom = true;
      _sphereScale = 1.0;
      _interactive = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default values'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

