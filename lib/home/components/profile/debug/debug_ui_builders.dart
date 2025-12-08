import 'package:flutter/material.dart';
import 'debug_panel_theme.dart';

/// Reusable UI building widgets for the debug panel
class DebugUIBuilders {
  final DebugPanelTheme theme;
  final String? expandedSection;
  final void Function(String?) onSectionToggle;

  DebugUIBuilders({
    required this.theme,
    required this.expandedSection,
    required this.onSectionToggle,
  });

  /// Build a collapsible section with header
  Widget buildSection({
    required String id,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final t = theme;
    final isExpanded = expandedSection == id;

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
            onTap: () => onSectionToggle(isExpanded ? null : id),
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

  /// Build a slider control
  Widget buildSlider(
    String label, 
    double value, 
    double min, 
    double max, 
    ValueChanged<double> onChanged,
  ) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: t.textSecondary),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.orange,
                inactiveTrackColor: t.border,
                thumbColor: Colors.orange,
                overlayColor: Colors.orange.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 42,
            child: Text(
              value.toStringAsFixed(value < 10 ? 2 : 1),
              style: TextStyle(fontSize: 11, color: t.textMuted, fontFamily: 'monospace'),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a toggle switch
  Widget buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  /// Build an enum picker
  Widget buildEnumPicker<T extends Enum>(
    String label,
    T selected,
    List<T> values,
    ValueChanged<T> onChanged,
  ) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ),
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: t.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: selected,
                  isExpanded: true,
                  dropdownColor: t.surface,
                  style: TextStyle(fontSize: 12, color: t.text),
                  icon: Icon(Icons.unfold_more, size: 16, color: t.textMuted),
                  items: values.map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v.name, style: TextStyle(color: t.text)),
                  )).toList(),
                  onChanged: (v) => v != null ? onChanged(v) : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a layer toggle row
  Widget buildLayerToggle(
    String label, 
    IconData icon, 
    bool value, 
    ValueChanged<bool> onChanged,
  ) {
    final t = theme;
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

  /// Build a color row with preview
  Widget buildColorRow(
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: t.border),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: TextStyle(fontSize: 11, color: t.textMuted, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a preset tile button
  Widget buildPresetTile(String name, String desc, VoidCallback onTap) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.text)),
                  Text(desc, style: TextStyle(fontSize: 10, color: t.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: t.textMuted),
          ],
        ),
      ),
    );
  }

  /// Build a palette tile for color selection
  Widget buildPaletteTile(ColorPalette palette, VoidCallback onTap) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
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

  /// Build a random palette button
  Widget buildRandomPaletteButton(String label, List<Color> gradientColors, VoidCallback onTap) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors.map((c) => c.withValues(alpha: 0.3)).toList(),
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shuffle, size: 18, color: t.text),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.text)),
          ],
        ),
      ),
    );
  }
}



