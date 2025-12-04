import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/home_colors.dart';

part 'awaway_geometry.dart';

const Color _ink = Color(0xFF2B2B3C);
const Color _muted = Color(0xFF6E6677);

class AwawaySection extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final double progress;
  final List<AwawayMilestone> milestones;
  final bool canRepair;

  const AwawaySection({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.progress,
    required this.milestones,
    required this.canRepair,
  });

  @override
  Widget build(BuildContext context) {
    final _GeometryStageData currentStage = _stageForDay(currentDay);
    final double safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 160 + safeBottom),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AWAWAY streak • Day $currentDay of $cycleLength',
                    style: TextStyle(
                      color: _muted,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Let the sacred geometry bloom',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AwawayGeometryPanel(
                    currentDay: currentDay,
                    cycleLength: cycleLength,
                    progress: progress,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Unlocked geometries',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GeometryHistoryTimeline(
                    currentDay: currentDay,
                    cycleLength: cycleLength,
                    milestones: milestones,
                  ),
                  const SizedBox(height: 24),
                  if (canRepair) _buildRepairCard(),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GeometryActionBar(
              stage: currentStage,
              onDownload: () => _showGeometryDownloadSheet(context, currentStage),
              onOrderMerch: () => _showGeometryMerchSheet(
                context,
                currentStage,
                currentDay,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE9D4), Color(0xFFFCB29C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bolt,
            color: Color(0xFF2B2B3C),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Need to repair the portal?',
                  style: TextStyle(
                    color: Color(0xFF2B2B3C),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Spend 15 Lumens to mend the geometry before it resets.',
                  style: TextStyle(
                    color: Color(0xFF2B2B3C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B2B3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Repair'),
          ),
        ],
      ),
    );
  }
}

class _GeometryActionBar extends StatelessWidget {
  final _GeometryStageData stage;
  final VoidCallback onDownload;
  final VoidCallback onOrderMerch;

  const _GeometryActionBar({
    required this.stage,
    required this.onDownload,
    required this.onOrderMerch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 32,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: OutlinedButton(
                onPressed: onDownload,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: BorderSide(color: HomeColors.peach.withOpacity(0.4)),
                  foregroundColor: _ink,
                  padding: EdgeInsets.zero,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.download_rounded),
                    SizedBox(height: 4),
                    Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: onOrderMerch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Order merch',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Text(
                        stage.label,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showGeometryDownloadSheet(BuildContext context, _GeometryStageData stage) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (sheetContext) {
      return _GeometrySheetContent(
        icon: Icons.picture_as_pdf_outlined,
        title: 'Download ${stage.label}',
        description:
            'We’ll render this geometry as a math-perfect PDF so you can print, frame, or share it. '
            'Tap below to queue the render — we’ll notify you once the file is ready.',
        primaryLabel: 'Prepare PDF',
        onPrimary: () {
          Navigator.of(sheetContext).pop();
          messenger?.showSnackBar(
            const SnackBar(content: Text('PDF rendering request saved.')),
          );
        },
        extra: const [
          Text(
            'Downloads remain exclusive to your unlocked geometries.',
            style: TextStyle(color: _muted),
          ),
        ],
      );
    },
  );
}

Future<void> _showGeometryMerchSheet(
  BuildContext context,
  _GeometryStageData stage,
  int currentDay,
) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final String redeemCode = _geometryRedeemCode(stage, currentDay);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (sheetContext) {
      return _GeometrySheetContent(
        icon: Icons.storefront_outlined,
        title: 'Order merch • ${stage.label}',
        description:
            'Each unlocked geometry unlocks a matching merch drop. Use the redeem code below when '
            'ordering on the official AWA store so we can verify your portal.',
        primaryLabel: 'Copy instructions',
        onPrimary: () {
          Navigator.of(sheetContext).pop();
          messenger?.showSnackBar(
            SnackBar(content: Text('Redeem details sent for ${stage.label}.')),
          );
        },
        extra: [
          const Text(
            'Redeem code',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: HomeColors.cream,
            ),
            child: Row(
              children: [
                const Icon(Icons.key_rounded, color: _ink),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableText(
                    redeemCode,
                    style: const TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Share this voucher only when you are ready to order so we can reserve the merch for you.',
            style: TextStyle(color: _muted.withOpacity(0.9)),
          ),
        ],
      );
    },
  );
}

class _GeometrySheetContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final List<Widget>? extra;

  const _GeometrySheetContent({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimary,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: _ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(color: _muted, height: 1.4),
          ),
          if (extra != null) ...[
            const SizedBox(height: 16),
            ...extra!,
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeColors.peach,
                foregroundColor: _ink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}

String _geometryRedeemCode(_GeometryStageData stage, int currentDay) {
  final String slug =
      stage.label.replaceAll(RegExp('[^A-Za-z]'), '').toUpperCase().padRight(4, 'X').substring(0, 4);
  final String dayCode = currentDay.toString().padLeft(2, '0');
  return 'AWA-$dayCode-$slug';
}

class _GeometryHistoryTimeline extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final List<AwawayMilestone> milestones;

  const _GeometryHistoryTimeline({
    required this.currentDay,
    required this.cycleLength,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _geometryStages.length; i++)
          _HistoryEntry(
            stage: _geometryStages[i],
            isUnlocked: currentDay >= _geometryStages[i].unlockDay,
            isLast: i == _geometryStages.length - 1,
            milestone: _milestoneForDay(_geometryStages[i].unlockDay),
          ),
      ],
    );
  }

  AwawayMilestone? _milestoneForDay(int day) {
    try {
      return milestones.firstWhere((m) => m.day == day);
    } catch (_) {
      return null;
    }
  }
}

class _HistoryEntry extends StatelessWidget {
  final _GeometryStageData stage;
  final bool isUnlocked;
  final bool isLast;
  final AwawayMilestone? milestone;

  const _HistoryEntry({
    required this.stage,
    required this.isUnlocked,
    required this.isLast,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CustomPaint(
                size: const Size(52, 52),
                painter: _TimelineGlyphPainter(
                  figure: stage.figure,
                  isUnlocked: isUnlocked,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: isUnlocked ? HomeColors.peach : Colors.black12,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.label,
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.description,
                  style: TextStyle(
                    color: _muted,
                    height: 1.3,
                  ),
                ),
                if (milestone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    milestone!.description,
                    style: TextStyle(
                      color: _muted.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      isUnlocked ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: isUnlocked ? HomeColors.peach : Colors.black26,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isUnlocked
                          ? 'Unlocked on day ${stage.unlockDay}'
                          : 'Unlocks on day ${stage.unlockDay}',
                      style: TextStyle(
                        color: isUnlocked ? _ink : _muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineGlyphPainter extends CustomPainter {
  final GeometryFigure figure;
  final bool isUnlocked;

  _TimelineGlyphPainter({required this.figure, required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final offset = size.center(Offset.zero);
    final double radius = size.width * 0.3;
    final Paint paint =
        Paint()
          ..color = isUnlocked ? HomeColors.peach : Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final Paint fillPaint =
        Paint()
          ..color = paint.color.withOpacity(isUnlocked ? 0.35 : 0.15)
          ..style = PaintingStyle.fill;

    switch (figure) {
      case GeometryFigure.circle:
        _drawCircle(canvas, offset, radius, paint);
        break;
      case GeometryFigure.vesicaPiscis:
        _drawVesicaPiscis(canvas, offset, radius * 0.95, paint);
        break;
      case GeometryFigure.tripod:
        _drawTripodOfLife(canvas, offset, radius * 0.9, paint);
        break;
      case GeometryFigure.seedOfLife:
        _drawSeedOfLife(canvas, offset, radius * 0.85, paint);
        break;
      case GeometryFigure.seedExpansion:
        _drawSeedHalo(canvas, offset, radius * 0.7, paint);
        break;
      case GeometryFigure.flowerOfLife:
        _drawFlowerOfLifeGrid(canvas, offset, radius * 0.6, paint);
        break;
      case GeometryFigure.fruitOfLife:
        _drawFruitOfLife(canvas, offset, radius * 0.9, paint, fillPaint);
        break;
      case GeometryFigure.tetrahedron:
        _drawTetrahedron(canvas, offset, radius * 0.85, paint);
        break;
      case GeometryFigure.cube:
        _drawHexahedron(canvas, offset, radius * 0.7, paint);
        break;
      case GeometryFigure.octahedron:
        _drawOctahedron(canvas, offset, radius * 0.85, paint);
        break;
      case GeometryFigure.icosahedron:
        _drawIcosahedron(canvas, offset, radius * 0.8, paint);
        break;
      case GeometryFigure.dodecahedron:
        _drawDodecahedron(canvas, offset, radius * 0.8, paint);
        break;
      case GeometryFigure.metatronCube:
        _drawMetatronCube(canvas, offset, radius * 0.9, paint, fillPaint);
        break;
      case GeometryFigure.merkaba:
        _drawMerkaba(canvas, offset, radius * 0.9, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineGlyphPainter oldDelegate) {
    return oldDelegate.figure != figure || oldDelegate.isUnlocked != isUnlocked;
  }
}

class AwawayMilestone {
  final int day;
  final String label;
  final String description;

  const AwawayMilestone({
    required this.day,
    required this.label,
    required this.description,
  });
}
