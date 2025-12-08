import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../soul/awa_sphere.dart';
import '../../../soul/awa_soul_settings.dart';
import '../../../globe/globe_widget.dart';
import '../../../globe/globe_states.dart';
import 'debug/debug_panel_theme.dart';
import 'debug/debug_ui_builders.dart';
import 'debug/debug_3d_tab.dart';
import 'debug/debug_2d_tab.dart';
import 'debug/debug_sphere_tab.dart';
import 'debug/debug_globe_tab.dart';

/// Full-screen AwaSoul debug page with layer-based controls
/// Features a sliding panel that minimizes visual obstruction
class AwaSoulDebugScreen extends StatefulWidget {
  const AwaSoulDebugScreen({super.key});

  @override
  State<AwaSoulDebugScreen> createState() => _AwaSoulDebugScreenState();
}

class _AwaSoulDebugScreenState extends State<AwaSoulDebugScreen> {
  final _settings = AwaSoulSettings();
  final _globeSettings = GlobeDebugSettings();

  // Panel state
  double _panelHeight = 0.35;
  static const double _minPanel = 0.12;
  static const double _maxPanel = 0.65;

  // Layer tab
  int _selectedLayer = 0; // 0=3D, 1=2D, 2=Sphere, 3=Globe

  // Expanded section within current layer
  String? _expandedSection;

  // Current theme based on background
  DebugPanelTheme get _theme => DebugPanelTheme.fromBackground(_settings.sphere.isDarkBackground);

  // Pending color picker context
  String? _pendingColorTarget;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    _globeSettings.addListener(_onSettingsChanged);
    print('AwaSoulDebugScreen: initState');
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    _globeSettings.removeListener(_onSettingsChanged);
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
          // === SPHERE PREVIEW ===
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
                  Expanded(child: _buildSpherePreview(sphereHeight)),
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
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, color: iconColor.withValues(alpha: 0.6), size: 18),
            onPressed: _copySettings,
            tooltip: 'Copy settings',
          ),
          TextButton(
            onPressed: () {
              print('AwaSoulDebugScreen: Reset pressed for layer $_selectedLayer');
              if (_selectedLayer == 0) {
                _settings.reset3D();
              } else if (_selectedLayer == 1) {
                _settings.reset2D();
              } else if (_selectedLayer == 2) {
                _settings.resetToDefaults();
              } else {
                _globeSettings.resetToDefaults();
              }
            },
            child: const Text('Reset', style: TextStyle(fontSize: 12, color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpherePreview(double height) {
    // Show blended layers when globe tab is selected
    if (_selectedLayer == 3) {
      print('AwaSoulDebugScreen: Globe tab - blending layers');
      return Stack(
        children: [
          // Base layer: Globe (if enabled)
          if (_globeSettings.showGlobe)
            Positioned.fill(
              child: Opacity(
                opacity: _globeSettings.earthOpacity,
                child: GlobeWidget(
                  config: GlobeConfig.globe(
                    height: double.infinity,
                    showUserLight: _globeSettings.showUserLight,
                    userLatitude: _globeSettings.userLatitude,
                    userLongitude: _globeSettings.userLongitude,
                  ),
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          // Overlay: AwaSphere (3D + 2D particles)
          if (_settings.layer3D.enabled || _settings.layer2D.enabled)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: _globeSettings.particleOverlayOpacity,
                  child: AwaSphere(
                    height: height,
                    useGlobalSettings: true,
                    interactive: false,
                  ),
                ),
              ),
            ),
        ],
      );
    }
    return AwaSphere(height: height, useGlobalSettings: true, interactive: true);
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
          _buildDragHandle(),
          // Layer tabs
          _buildLayerTabs(),
          Divider(color: t.divider, height: 1),
          // Settings content
          Expanded(child: _buildLayerSettings()),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    final t = _theme;
    return GestureDetector(
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
    );
  }

  Widget _buildLayerTabs() {
    final t = _theme;
    final tabs = [
      ('3D', Icons.blur_on, _settings.layer3D.enabled),
      ('2D', Icons.gradient, _settings.layer2D.enabled),
      ('Sphere', Icons.circle_outlined, true),
      ('Globe', Icons.public, true),
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
                    // Only show visibility toggle for 3D and 2D layers
                    if (index < 2) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            _settings.update3D((s) => s.copyWith(enabled: !s.enabled));
                          } else if (index == 1) {
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
    final ui = DebugUIBuilders(
      theme: _theme,
      expandedSection: _expandedSection,
      onSectionToggle: (id) => setState(() => _expandedSection = id),
    );

    switch (_selectedLayer) {
      case 0:
        return Debug3DTab(
          settings: _settings,
          ui: ui,
          openColorPicker: (color) => _openColorPicker(color, '3d'),
        );
      case 1:
        return Debug2DTab(
          settings: _settings,
          ui: ui,
          openColorPicker: (color) => _openColorPicker(color, '2d'),
        );
      case 2:
        return DebugSphereTab(
          settings: _settings,
          ui: ui,
          openColorPicker: (color) => _openColorPicker(color, 'sphere'),
        );
      case 3:
        return DebugGlobeTab(
          settings: _globeSettings,
          soulSettings: _settings,
          ui: ui,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _openColorPicker(Color initialColor, String target) {
    _pendingColorTarget = target;
    
    int r = (initialColor.r * 255).round();
    int g = (initialColor.g * 255).round();
    int b = (initialColor.b * 255).round();
    Color pickedColor = initialColor;
    final hexController = TextEditingController(
      text: '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void updateFromRGB() {
              pickedColor = Color.fromARGB(255, r, g, b);
              hexController.text = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
            }

            void updateFromHex(String hex) {
              hex = hex.replaceAll('#', '').replaceAll('0x', '');
              if (hex.length == 6) {
                try {
                  r = int.parse(hex.substring(0, 2), radix: 16);
                  g = int.parse(hex.substring(2, 4), radix: 16);
                  b = int.parse(hex.substring(4, 6), radix: 16);
                  pickedColor = Color.fromARGB(255, r, g, b);
                  setDialogState(() {});
                } catch (_) {}
              }
            }

            final t = _theme;
            
            return AlertDialog(
              backgroundColor: t.surface,
              title: Text('Pick Color', style: TextStyle(color: t.text, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Color preview with hex
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: pickedColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: t.border),
                      ),
                      child: Center(
                        child: Text(
                          hexController.text,
                          style: TextStyle(
                            color: getContrastColor(pickedColor),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // HEX input
                    TextField(
                      controller: hexController,
                      style: TextStyle(color: t.text, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        labelText: 'HEX',
                        labelStyle: TextStyle(color: t.textSecondary),
                        hintText: '#FF6A14',
                        hintStyle: TextStyle(color: t.textMuted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: t.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (value) {
                        updateFromHex(value);
                      },
                      onChanged: (value) {
                        if (value.length >= 6) {
                          updateFromHex(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // RGB Sliders
                    _buildColorSlider('R', r, Colors.red, t, (v) {
                      setDialogState(() {
                        r = v;
                        updateFromRGB();
                      });
                    }),
                    _buildColorSlider('G', g, Colors.green, t, (v) {
                      setDialogState(() {
                        g = v;
                        updateFromRGB();
                      });
                    }),
                    _buildColorSlider('B', b, Colors.blue, t, (v) {
                      setDialogState(() {
                        b = v;
                        updateFromRGB();
                      });
                    }),
                    const SizedBox(height: 12),

                    // Quick swatches
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Colors.white,
                        const Color(0xFFFFFAE0),
                        const Color(0xFFFF6A14),
                        const Color(0xFFFF3533),
                        const Color(0xFFF91A4D),
                        const Color(0xFFDD0F6F),
                        const Color(0xFFA40A97),
                        const Color(0xFF6A05B9),
                        const Color(0xFF3080A0),
                        const Color(0xFF2D6A4F),
                      ].map((c) => GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            r = (c.r * 255).round();
                            g = (c.g * 255).round();
                            b = (c.b * 255).round();
                            updateFromRGB();
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: t.border),
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: t.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    _applyPickedColor(pickedColor);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply', style: TextStyle(color: Colors.orange)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorSlider(String label, int value, Color color, DebugPanelTheme t, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(label, style: TextStyle(color: t.textSecondary, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.3),
                thumbColor: color,
              ),
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 255,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(value.toString(), style: TextStyle(color: t.textMuted, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _applyPickedColor(Color color) {
    // This is simplified - in practice you'd track which specific color field was being edited
    // For now, we'll need to handle this through the specific tab callbacks
    print('AwaSoulDebugScreen: Color picked: $color for target $_pendingColorTarget');
  }
}
