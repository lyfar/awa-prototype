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
  final Map<String, TextEditingController> _colorControllers = {};
  final Map<String, String?> _colorErrors = {};

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    _syncColorControllers();
  }
  
  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    for (final controller in _colorControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _onSettingsChanged() {
    _syncColorControllers();
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
      key: ValueKey(
        'sphere_${_settings.flickerSpeed}_${_settings.pulseSpeed}_${_settings.driftSpeed}_${_settings.gradientStart.value}_${_settings.gradientMid.value}_${_settings.gradientEnd.value}_${_settings.showBackdrop}_${_settings.showParticles}',
      ),
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
              _buildSwitch(
                'Show particles',
                'Toggle all 3D light points on/off',
                _settings.showParticles,
                (v) => setState(() => _settings.showParticles = v),
              ),
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
              _buildSwitch(
                'Show backdrop',
                'Toggle spiral dots and gradient',
                _settings.showBackdrop,
                (v) => setState(() => _settings.showBackdrop = v),
              ),
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _applySaturatedBackdropPalette,
                  icon: const Icon(Icons.auto_fix_high, size: 16, color: Colors.deepOrange),
                  label: const Text('Saturated preset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                    side: const BorderSide(color: Colors.deepOrangeAccent),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
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
    final key = 'color_$label';
    final controller = _controllerFor(key, color);
    final errorText = _colorErrors[key];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 50, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
              const SizedBox(width: 8),
              ..._colorPresets.map((preset) => Padding(
                padding: const EdgeInsets.only(right: 5),
                child: GestureDetector(
                  onTap: () {
                    _colorErrors[key] = null;
                    onChanged(preset);
                  },
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
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: TextField(
              controller: controller,
              onSubmitted: (_) => _applyCustomColor(key, controller.text, onChanged),
              decoration: InputDecoration(
                labelText: 'Custom hex',
                hintText: '#FFA573',
                errorText: errorText,
                prefixIcon: const Icon(Icons.colorize, size: 16),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
                labelStyle: const TextStyle(color: Colors.black87),
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              style: const TextStyle(color: Colors.black87),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Fa-f0-9#]')),
              ],
              textCapitalization: TextCapitalization.characters,
            ),
          ),
          TextButton(
            onPressed: () => _openColorPicker(label, color, onChanged, key),
            child: const Text('Pick color'),
          ),
        ],
      ),
    );
  }
  
  static const List<Color> _colorPresets = [
    Color(0xFFFFD7C0), // default center
    Color(0xFFFFBFA1),
    Color(0xFFFFA573), // default mid
    Color(0xFFFF8B7A),
    Color(0xFFFF7BC5), // default edge
    Color(0xFFE86BAF),
    Color(0xFFD08CF2),
    Color(0xFFB76DE0),
  ];

  void _applySaturatedBackdropPalette() {
    setState(() {
      _settings.gradientStart = const Color(0xFFFFD7C0); // peach cream
      _settings.gradientMid = const Color(0xFFFFA573);   // apricot
      _settings.gradientEnd = const Color(0xFFFF7BC5);   // vivid rosy glow
    });
  }

  TextEditingController _controllerFor(String key, Color color) {
    final hex = _formatColorHex(color);
    final existing = _colorControllers[key];
    if (existing != null) {
      if (existing.text.toUpperCase() != hex) {
        existing.text = hex;
      }
      return existing;
    }
    final controller = TextEditingController(text: hex);
    _colorControllers[key] = controller;
    return controller;
  }

  void _applyCustomColor(String key, String input, ValueChanged<Color> onChanged) {
    final color = _parseColor(input);
    if (color == null) {
      setState(() {
        _colorErrors[key] = 'Use #RRGGBB or RRGGBB';
      });
      return;
    }
    setState(() {
      _colorErrors[key] = null;
      onChanged(color);
    });
  }

  String _formatColorHex(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${value.substring(2)}';
  }

  Color? _parseColor(String input) {
    var hex = input.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) return null;
    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  void _syncColorControllers() {
    _controllerFor('color_Center', _settings.gradientStart);
    _controllerFor('color_Middle', _settings.gradientMid);
    _controllerFor('color_Edge', _settings.gradientEnd);
  }

  Future<void> _openColorPicker(
    String label,
    Color initialColor,
    ValueChanged<Color> onChanged,
    String key,
  ) async {
    Color tempColor = initialColor;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$label color'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: tempColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Color.r/g/b return 0.0-1.0 floats, so multiply by 255 for slider display
                  // and divide by 255 when setting values
                  _buildChannelSlider(
                    'R',
                    tempColor.r * 255,
                    (v) => setState(() {
                      tempColor = tempColor.withValues(
                        red: v / 255,
                        green: tempColor.g,
                        blue: tempColor.b,
                        alpha: tempColor.a,
                      );
                    }),
                  ),
                  _buildChannelSlider(
                    'G',
                    tempColor.g * 255,
                    (v) => setState(() {
                      tempColor = tempColor.withValues(
                        red: tempColor.r,
                        green: v / 255,
                        blue: tempColor.b,
                        alpha: tempColor.a,
                      );
                    }),
                  ),
                  _buildChannelSlider(
                    'B',
                    tempColor.b * 255,
                    (v) => setState(() {
                      tempColor = tempColor.withValues(
                        red: tempColor.r,
                        green: tempColor.g,
                        blue: v / 255,
                        alpha: tempColor.a,
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _colorErrors[key] = null;
                Navigator.of(context).pop();
                setState(() {
                  onChanged(tempColor);
                });
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChannelSlider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 18, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            activeColor: Colors.deepOrange,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toInt().toString().padLeft(3, ' '),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
