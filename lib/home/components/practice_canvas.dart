import 'package:flutter/material.dart';

import '../../widgets/spiral_backdrop.dart';

const double _canvasSpiralBleedFactor = 1.4;
const LinearGradient _canvasSpiralOverlay = LinearGradient(
  colors: [Color(0xB3FFFFFF), Color(0x66FFFFFF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

class PracticeCanvas extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> scriptLines;
  final List<PracticeMetaChipData> metaChips;
  final String primaryLabel;
  final bool isPrimaryEnabled;
  final VoidCallback? onPrimary;
  final VoidCallback? onBack;
  final bool disableSoulInteraction;

  const PracticeCanvas({
    super.key,
    required this.title,
    required this.subtitle,
    required this.scriptLines,
    required this.metaChips,
    required this.primaryLabel,
    required this.isPrimaryEnabled,
    this.onPrimary,
    this.onBack,
    this.disableSoulInteraction = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double canvasHeight =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0 ? constraints.maxHeight : 600;
        final double bleedHeight = canvasHeight * _canvasSpiralBleedFactor;

        return Container(
          key: const ValueKey('practice_canvas'),
          color: const Color(0xFFFAFAFA),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SpiralBackdrop(
                height: canvasHeight,
                bleedFactor: _canvasSpiralBleedFactor,
                offsetFactor: 0.5,
                overlayGradient: _canvasSpiralOverlay,
                disableInteraction: disableSoulInteraction,
                showParticles: false,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 36, 32, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF2B2B3C),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _MetaWrap(metaChips: metaChips),
                      const SizedBox(height: 30),
                      _ScriptCard(scriptLines: scriptLines),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 32,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: onBack,
                      child: const Text(
                        'Back to globe',
                        style: TextStyle(
                          color: Color(0xFF2B2B3C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: isPrimaryEnabled ? onPrimary : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B1B26),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class PracticeMetaChipData {
  final IconData icon;
  final String label;

  const PracticeMetaChipData({
    required this.icon,
    required this.label,
  });
}

class _MetaWrap extends StatelessWidget {
  final List<PracticeMetaChipData> metaChips;

  const _MetaWrap({required this.metaChips});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: metaChips
          .map(
            (chip) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1EB),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFFD5C1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    chip.icon,
                    color: const Color(0xFF685B6D),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    chip.label,
                    style: const TextStyle(
                      color: Color(0xFF2B2B3C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ScriptCard extends StatelessWidget {
  final List<String> scriptLines;

  const _ScriptCard({required this.scriptLines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFFFDF7F3),
        border: Border.all(
          color: const Color(0xFFFFE0CC),
        ),
      ),
      child: Column(
        children: scriptLines
            .map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        color: Color(0xFF685B6D),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: Color(0xFF2B2B3C),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
