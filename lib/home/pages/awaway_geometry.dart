part of 'awaway_section.dart';

class AwawayGeometryPanel extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final double progress;

  const AwawayGeometryPanel({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final double normalizedProgress = progress.clamp(0, 1);
    final int portalsLit = (normalizedProgress * cycleLength).floor();
    final int portalsLeft = (cycleLength - portalsLit).clamp(0, cycleLength);
    final _GeometryStageData currentStage = _stageForDay(currentDay);
    final _GeometryStageData? nextStage = _nextStageAfter(currentDay);
    final int unlockedStages = (_geometryStages
            .where((stage) => currentDay >= stage.unlockDay)
            .length)
        .clamp(1, _geometryStages.length);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: HomeColors.cream,
        border: Border.all(color: HomeColors.rose.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final double figureSize = constraints.maxWidth;
              return SizedBox(
                height: figureSize,
                width: figureSize,
                child: CustomPaint(
                  painter: _GeometryPainter(
                    progress: normalizedProgress,
                    unlockedStages: unlockedStages,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$portalsLit portals',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${portalsLeft} to ignite',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current figure • ${currentStage.label}',
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentStage.description,
                style: TextStyle(color: _muted, height: 1.4),
              ),
              if (nextStage != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Next: ${nextStage.label} on day ${nextStage.unlockDay}',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric('Current portal', 'Day $currentDay'),
              _metric('Cycle length', '$cycleLength days'),
              _metric('Next ceremony', portalsLeft == 0 ? 'Reset soon' : 'In $portalsLeft day(s)'),
            ],
          ),
          if (portalsLeft == 0) ...[
            const SizedBox(height: 12),
            _SuperLightUnlockedBanner(
              onActivate: () => _showSuperLightSheet(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: _muted, fontSize: 11),
        ),
      ],
    );
  }
}

void _showSuperLightSheet(BuildContext context) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetContext).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.auto_awesome, color: _ink, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ignite Super Light',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Lighting a Super Light broadcasts your portal to all AWA users. '
              'It also resets your geometry streak so you can begin a new bloom.',
              style: TextStyle(color: _muted, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HomeColors.cream,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.warning_amber_rounded, color: _ink),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your current portals will be cleared when the Super Light is fired. '
                      'This keeps the globe lit but starts your streak back at day one.',
                      style: TextStyle(color: _ink, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  messenger?.showSnackBar(
                    const SnackBar(content: Text('Super Light queued — watch the globe glow.')),
                  );
                },
                icon: const Icon(Icons.auto_fix_high_outlined),
                label: const Text('Light Super Light'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeColors.peach,
                  foregroundColor: _ink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _SuperLightUnlockedBanner extends StatelessWidget {
  final VoidCallback onActivate;

  const _SuperLightUnlockedBanner({required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            HomeColors.peach.withOpacity(0.35),
            HomeColors.rose.withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: _ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Super light unlocked',
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You can now light a Super Light anywhere on the globe to celebrate the full geometry.',
                  style: TextStyle(color: _muted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onActivate,
            style: ElevatedButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text(
              'Light it',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeometryStageData {
  final String label;
  final String description;
  final int unlockDay;
  final GeometryFigure figure;

  const _GeometryStageData({
    required this.label,
    required this.description,
    required this.unlockDay,
    required this.figure,
  });
}

enum GeometryFigure {
  circle,
  vesicaPiscis,
  tripod,
  seedOfLife,
  seedExpansion,
  flowerOfLife,
  fruitOfLife,
  tetrahedron,
  cube,
  octahedron,
  icosahedron,
  dodecahedron,
  metatronCube,
  merkaba,
}

const List<_GeometryStageData> _geometryStages = [
  _GeometryStageData(
    label: 'Circle of unity',
    description: 'All points return to the center; wholeness anchored.',
    unlockDay: 1,
    figure: GeometryFigure.circle,
  ),
  _GeometryStageData(
    label: 'Vesica gateway',
    description: 'Two worlds overlap to birth a shared field.',
    unlockDay: 4,
    figure: GeometryFigure.vesicaPiscis,
  ),
  _GeometryStageData(
    label: 'Tripod of life',
    description: 'Three intersecting suns form a stabilizing tripod.',
    unlockDay: 7,
    figure: GeometryFigure.tripod,
  ),
  _GeometryStageData(
    label: 'Seed of Life',
    description: 'Seven circles pulse as the primordial bloom.',
    unlockDay: 10,
    figure: GeometryFigure.seedOfLife,
  ),
  _GeometryStageData(
    label: 'Seed halo',
    description: 'Six more petals lock in, forming a protective lattice.',
    unlockDay: 13,
    figure: GeometryFigure.seedExpansion,
  ),
  _GeometryStageData(
    label: 'Flower of Life',
    description: 'Nineteen rings weave the full Flower of Life tapestry.',
    unlockDay: 16,
    figure: GeometryFigure.flowerOfLife,
  ),
  _GeometryStageData(
    label: 'Fruit of Life matrix',
    description: 'Thirteen nodes illuminate — blueprint for forms.',
    unlockDay: 19,
    figure: GeometryFigure.fruitOfLife,
  ),
  _GeometryStageData(
    label: 'Tetrahedron • FIRE',
    description: 'First Platonic solid ignites upward motion.',
    unlockDay: 22,
    figure: GeometryFigure.tetrahedron,
  ),
  _GeometryStageData(
    label: 'Hexahedron • EARTH',
    description: 'Cube anchors roots, grounding the ceremony.',
    unlockDay: 25,
    figure: GeometryFigure.cube,
  ),
  _GeometryStageData(
    label: 'Octahedron • AIR',
    description: 'Dual pyramids breathe in equilibrium.',
    unlockDay: 28,
    figure: GeometryFigure.octahedron,
  ),
  _GeometryStageData(
    label: 'Icosahedron • WATER',
    description: 'Twenty faces shimmer like a moving tide.',
    unlockDay: 31,
    figure: GeometryFigure.icosahedron,
  ),
  _GeometryStageData(
    label: 'Dodecahedron • SPIRIT',
    description: 'Twelve pentagons open the spirit vault.',
    unlockDay: 34,
    figure: GeometryFigure.dodecahedron,
  ),
  _GeometryStageData(
    label: 'Metatron’s Cube',
    description: 'All centering points connect; grid intelligence online.',
    unlockDay: 37,
    figure: GeometryFigure.metatronCube,
  ),
  _GeometryStageData(
    label: 'Merkaba avatar',
    description: 'Interlocking tetrahedrons spin — avatar body lit.',
    unlockDay: 40,
    figure: GeometryFigure.merkaba,
  ),
];

const Map<GeometryFigure, double> _figureExtentMultiplier = {
  GeometryFigure.circle: 0.85,
  GeometryFigure.vesicaPiscis: 1.1,
  GeometryFigure.tripod: 1.12,
  GeometryFigure.seedOfLife: 0.96,
  GeometryFigure.seedExpansion: 1.32,
  GeometryFigure.flowerOfLife: 1.92,
  GeometryFigure.fruitOfLife: 1.18,
  GeometryFigure.tetrahedron: 0.9,
  GeometryFigure.cube: 0.85,
  GeometryFigure.octahedron: 0.8,
  GeometryFigure.icosahedron: 0.92,
  GeometryFigure.dodecahedron: 0.95,
  GeometryFigure.metatronCube: 0.9,
  GeometryFigure.merkaba: 0.9,
};

bool _isFigureUnlocked(GeometryFigure figure, int unlockedStages) {
  final int index = _geometryStages.indexWhere((stage) => stage.figure == figure);
  return index >= 0 && index < unlockedStages;
}

double _canvasScaleForStages(int unlockedStages) {
  final double maxExtent = _maxExtentForUnlockedStages(unlockedStages);
  final double allowedScale = 1.25 / maxExtent;
  return math.min(1.0, allowedScale);
}

double _maxExtentForUnlockedStages(int unlockedStages) {
  double maxExtent = 1.0;
  for (int i = 0; i < unlockedStages && i < _geometryStages.length; i++) {
    final GeometryFigure figure = _geometryStages[i].figure;
    maxExtent = math.max(maxExtent, _figureExtentMultiplier[figure] ?? 1.0);
  }
  return maxExtent;
}

const double _sqrt3 = 1.7320508075688772;

const List<Offset> _fruitNodeBlueprint = [
  Offset(0, 0),
  Offset(1, 0),
  Offset(0.5, _sqrt3 / 2),
  Offset(-0.5, _sqrt3 / 2),
  Offset(-1, 0),
  Offset(-0.5, -_sqrt3 / 2),
  Offset(0.5, -_sqrt3 / 2),
  Offset(0, _sqrt3),
  Offset(1.5, _sqrt3 / 2),
  Offset(1.5, -_sqrt3 / 2),
  Offset(0, -_sqrt3),
  Offset(-1.5, -_sqrt3 / 2),
  Offset(-1.5, _sqrt3 / 2),
];

const List<Offset> _fruitOuterRing = [
  Offset(0, _sqrt3),
  Offset(1.5, _sqrt3 / 2),
  Offset(1.5, -_sqrt3 / 2),
  Offset(0, -_sqrt3),
  Offset(-1.5, -_sqrt3 / 2),
  Offset(-1.5, _sqrt3 / 2),
];

_GeometryStageData _stageForDay(int day) {
  _GeometryStageData current = _geometryStages.first;
  for (final stage in _geometryStages) {
    if (day >= stage.unlockDay) {
      current = stage;
    }
  }
  return current;
}

_GeometryStageData? _nextStageAfter(int day) {
  for (final stage in _geometryStages) {
    if (stage.unlockDay > day) {
      return stage;
    }
  }
  return null;
}

class _GeometryPainter extends CustomPainter {
  final double progress;
  final int unlockedStages;

  _GeometryPainter({required this.progress, required this.unlockedStages});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final double scale = _canvasScaleForStages(unlockedStages);
    final double radius = size.width * 0.4 * scale;

    final Paint glowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [HomeColors.peach.withOpacity(0.35), Colors.transparent],
          ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.5));
    canvas.drawCircle(center, radius, glowPaint);

    final Paint strokePaint =
        Paint()
          ..color = HomeColors.rose.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
    final Paint highlightPaint =
        Paint()
          ..color = HomeColors.peach.withOpacity(0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
    final Paint structurePaint =
        Paint()
          ..color = HomeColors.peach.withOpacity(0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final Paint nodePaint =
        Paint()
          ..color = HomeColors.peach.withOpacity(0.55)
          ..style = PaintingStyle.fill;

    _drawCircle(canvas, center, radius * 0.85, strokePaint);

    if (_isFigureUnlocked(GeometryFigure.vesicaPiscis, unlockedStages)) {
      _drawVesicaPiscis(canvas, center, radius * 0.68, strokePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.tripod, unlockedStages)) {
      _drawTripodOfLife(canvas, center, radius * 0.6, strokePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.seedOfLife, unlockedStages)) {
      _drawSeedOfLife(canvas, center, radius * 0.48, highlightPaint);
    }
    if (_isFigureUnlocked(GeometryFigure.seedExpansion, unlockedStages)) {
      _drawSeedHalo(canvas, center, radius * 0.45, highlightPaint);
    }
    if (_isFigureUnlocked(GeometryFigure.flowerOfLife, unlockedStages)) {
      _drawFlowerOfLifeGrid(canvas, center, radius * 0.4, highlightPaint);
    }
    if (_isFigureUnlocked(GeometryFigure.fruitOfLife, unlockedStages)) {
      _drawFruitOfLife(canvas, center, radius * 0.42, highlightPaint, nodePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.tetrahedron, unlockedStages)) {
      _drawTetrahedron(canvas, center, radius * 0.32, structurePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.cube, unlockedStages)) {
      _drawHexahedron(canvas, center, radius * 0.3, structurePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.octahedron, unlockedStages)) {
      _drawOctahedron(canvas, center, radius * 0.28, structurePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.icosahedron, unlockedStages)) {
      _drawIcosahedron(canvas, center, radius * 0.26, structurePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.dodecahedron, unlockedStages)) {
      _drawDodecahedron(canvas, center, radius * 0.25, structurePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.metatronCube, unlockedStages)) {
      _drawMetatronCube(canvas, center, radius * 0.45, strokePaint, nodePaint);
    }
    if (_isFigureUnlocked(GeometryFigure.merkaba, unlockedStages)) {
      _drawMerkaba(canvas, center, radius * 0.3, structurePaint);
    }

    final Paint orbitPaint =
        Paint()
          ..color = HomeColors.peach.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
    final double sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.95),
      -math.pi / 2,
      sweep,
      false,
      orbitPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GeometryPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.unlockedStages != unlockedStages;
  }
}

void _drawCircle(Canvas canvas, Offset center, double radius, Paint paint) {
  canvas.drawCircle(center, radius, paint);
}

void _drawVesicaPiscis(Canvas canvas, Offset center, double radius, Paint paint) {
  final double offset = radius * 0.6;
  canvas.drawCircle(center.translate(-offset, 0), radius, paint);
  canvas.drawCircle(center.translate(offset, 0), radius, paint);
}

void _drawTripodOfLife(Canvas canvas, Offset center, double radius, Paint paint) {
  final double spacing = radius * 1.1;
  final double vertical = spacing * _sqrt3 / 2;
  canvas.drawCircle(center.translate(0, -vertical * 0.8), radius, paint);
  canvas.drawCircle(center.translate(-spacing / 2, vertical * 0.2), radius, paint);
  canvas.drawCircle(center.translate(spacing / 2, vertical * 0.2), radius, paint);
}

void _drawSeedOfLife(Canvas canvas, Offset center, double radius, Paint paint) {
  final double spacing = radius;
  final List<Offset> offsets = [
    Offset.zero,
    Offset(spacing, 0),
    Offset(-spacing, 0),
    Offset(spacing / 2, spacing * _sqrt3 / 2),
    Offset(-spacing / 2, spacing * _sqrt3 / 2),
    Offset(spacing / 2, -spacing * _sqrt3 / 2),
    Offset(-spacing / 2, -spacing * _sqrt3 / 2),
  ];
  for (final offset in offsets) {
    canvas.drawCircle(center + offset, radius, paint);
  }
}

void _drawSeedHalo(Canvas canvas, Offset center, double radius, Paint paint) {
  final double haloRadius = radius * 1.9;
  for (int i = 0; i < 6; i++) {
    final double angle = i * math.pi / 3;
    final double dx = haloRadius * math.cos(angle);
    final double dy = haloRadius * math.sin(angle);
    canvas.drawCircle(center.translate(dx, dy), radius * 0.85, paint);
  }
}

void _drawFlowerOfLifeGrid(Canvas canvas, Offset center, double circleRadius, Paint paint) {
  final double spacing = circleRadius * 1.05;
  for (int q = -2; q <= 2; q++) {
    for (int r = -2; r <= 2; r++) {
      final int s = -q - r;
      if (s < -2 || s > 2) continue;
      final double x = spacing * (math.sqrt(3) * q + math.sqrt(3) / 2 * r);
      final double y = spacing * (1.5 * r);
      canvas.drawCircle(center.translate(x, y), circleRadius, paint);
    }
  }
}

void _drawFruitOfLife(
  Canvas canvas,
  Offset center,
  double layoutRadius,
  Paint strokePaint,
  Paint fillPaint,
) {
  final double spacing = layoutRadius / _sqrt3;
  final double nodeRadius = layoutRadius * 0.12;
  final List<Offset> nodeCenters = _fruitNodeBlueprint
      .map((blueprint) => center.translate(blueprint.dx * spacing, blueprint.dy * spacing))
      .toList();

  for (final node in nodeCenters) {
    canvas.drawCircle(node, nodeRadius, fillPaint);
    canvas.drawCircle(node, nodeRadius, strokePaint);
  }

  final Path outerRing = Path();
  for (int i = 0; i < _fruitOuterRing.length; i++) {
    final Offset ringPoint = center.translate(
      _fruitOuterRing[i].dx * spacing,
      _fruitOuterRing[i].dy * spacing,
    );
    if (i == 0) {
      outerRing.moveTo(ringPoint.dx, ringPoint.dy);
    } else {
      outerRing.lineTo(ringPoint.dx, ringPoint.dy);
    }
  }
  outerRing.close();
  canvas.drawPath(outerRing, strokePaint);
}

void _drawTetrahedron(Canvas canvas, Offset center, double radius, Paint paint) {
  final Offset apex = center.translate(0, -radius * 1.2);
  final Offset baseCenter = center.translate(0, radius * 0.3);
  final List<Offset> basePoints = List.generate(3, (index) {
    final double angle = -math.pi / 2 + index * (2 * math.pi / 3);
    return Offset(
      baseCenter.dx + radius * math.cos(angle),
      baseCenter.dy + radius * math.sin(angle),
    );
  });

  final Path basePath = Path()..moveTo(basePoints.first.dx, basePoints.first.dy);
  for (int i = 1; i < basePoints.length; i++) {
    basePath.lineTo(basePoints[i].dx, basePoints[i].dy);
  }
  basePath.close();
  canvas.drawPath(basePath, paint);

  for (final vertex in basePoints) {
    canvas.drawLine(apex, vertex, paint);
  }
}

void _drawHexahedron(Canvas canvas, Offset center, double radius, Paint paint) {
  final double size = radius * 1.6;
  final Rect front = Rect.fromCenter(center: center, width: size, height: size);
  final Offset offset = Offset(-radius * 0.5, -radius * 0.5);
  final Rect back = front.shift(offset);

  canvas.drawRect(front, paint);
  canvas.drawRect(back, paint);

  canvas.drawLine(front.topLeft, back.topLeft, paint);
  canvas.drawLine(front.topRight, back.topRight, paint);
  canvas.drawLine(front.bottomLeft, back.bottomLeft, paint);
  canvas.drawLine(front.bottomRight, back.bottomRight, paint);
}

void _drawOctahedron(Canvas canvas, Offset center, double radius, Paint paint) {
  final Path outer = Path()
    ..moveTo(center.dx, center.dy - radius)
    ..lineTo(center.dx + radius * 0.85, center.dy)
    ..lineTo(center.dx, center.dy + radius)
    ..lineTo(center.dx - radius * 0.85, center.dy)
    ..close();
  canvas.drawPath(outer, paint);

  canvas.drawLine(center.translate(0, -radius), center.translate(0, radius), paint);
  canvas.drawLine(center.translate(-radius * 0.85, 0), center.translate(radius * 0.85, 0), paint);
}

void _drawIcosahedron(Canvas canvas, Offset center, double radius, Paint paint) {
  final List<Offset> points = List.generate(5, (index) {
    final double angle = -math.pi / 2 + index * (2 * math.pi / 5);
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  });

  final Path outer = Path()..moveTo(points.first.dx, points.first.dy);
  for (int i = 1; i < points.length; i++) {
    outer.lineTo(points[i].dx, points[i].dy);
  }
  outer.close();
  canvas.drawPath(outer, paint);

  for (int i = 0; i < points.length; i++) {
    canvas.drawLine(points[i], points[(i + 2) % points.length], paint);
  }
}

void _drawDodecahedron(Canvas canvas, Offset center, double radius, Paint paint) {
  final List<Offset> outer = List.generate(5, (index) {
    final double angle = -math.pi / 2 + index * (2 * math.pi / 5);
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  });
  final List<Offset> inner = List.generate(5, (index) {
    final double angle = -math.pi / 2 + index * (2 * math.pi / 5) + math.pi / 5;
    return Offset(
      center.dx + radius * 0.6 * math.cos(angle),
      center.dy + radius * 0.6 * math.sin(angle),
    );
  });

  final Path outerPath = Path()..moveTo(outer.first.dx, outer.first.dy);
  for (int i = 1; i < outer.length; i++) {
    outerPath.lineTo(outer[i].dx, outer[i].dy);
  }
  outerPath.close();
  canvas.drawPath(outerPath, paint);

  final Path innerPath = Path()..moveTo(inner.first.dx, inner.first.dy);
  for (int i = 1; i < inner.length; i++) {
    innerPath.lineTo(inner[i].dx, inner[i].dy);
  }
  innerPath.close();
  canvas.drawPath(innerPath, paint);

  for (int i = 0; i < outer.length; i++) {
    canvas.drawLine(outer[i], inner[i], paint);
  }
}

void _drawMetatronCube(
  Canvas canvas,
  Offset center,
  double layoutRadius,
  Paint strokePaint,
  Paint nodePaint,
) {
  final double spacing = layoutRadius / _sqrt3;
  final List<Offset> nodes = _fruitNodeBlueprint
      .map((blueprint) => center.translate(blueprint.dx * spacing, blueprint.dy * spacing))
      .toList();
  final Paint thinPaint =
      Paint()
        ..color = strokePaint.color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

  final Offset origin = nodes.first;
  for (int i = 1; i < nodes.length; i++) {
    canvas.drawLine(origin, nodes[i], thinPaint);
  }
  for (int i = 1; i <= 6; i++) {
    final Offset start = nodes[i];
    final Offset end = nodes[i == 6 ? 1 : i + 1];
    canvas.drawLine(start, end, thinPaint);

    final Offset outer = nodes[6 + i];
    canvas.drawLine(start, outer, thinPaint);
  }
  for (int i = 7; i < nodes.length; i++) {
    final Offset start = nodes[i];
    final Offset end = nodes[i == nodes.length - 1 ? 7 : i + 1];
    canvas.drawLine(start, end, thinPaint);
  }

  final double nodeRadius = layoutRadius * 0.07;
  for (final node in nodes) {
    canvas.drawCircle(node, nodeRadius, nodePaint);
  }
}

void _drawMerkaba(Canvas canvas, Offset center, double radius, Paint paint) {
  final Path upward = Path()
    ..moveTo(center.dx, center.dy - radius)
    ..lineTo(center.dx - radius * math.cos(math.pi / 6), center.dy + radius / 2)
    ..lineTo(center.dx + radius * math.cos(math.pi / 6), center.dy + radius / 2)
    ..close();
  final Path downward = Path()
    ..moveTo(center.dx, center.dy + radius)
    ..lineTo(center.dx - radius * math.cos(math.pi / 6), center.dy - radius / 2)
    ..lineTo(center.dx + radius * math.cos(math.pi / 6), center.dy - radius / 2)
    ..close();
  canvas.drawPath(upward, paint);
  canvas.drawPath(downward, paint);
}
