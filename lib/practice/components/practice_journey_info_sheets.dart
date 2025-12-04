part of 'package:awa_01_spark/practice/practice_journey_screen.dart';

class _PracticeInfoSheet extends StatelessWidget {
  final Practice practice;

  const _PracticeInfoSheet({required this.practice});

  @override
  Widget build(BuildContext context) {
    final chips = [
      practice.availabilityLabel,
      practice.durationLabel,
      practice.requiresMaster ? 'Master-led' : 'Self-guided',
      practice.downloadable ? 'Downloadable audio' : 'Streaming only',
    ];
    if (practice.minDuration != null) {
      chips.add('Min ${practice.minDuration!.inMinutes} min');
    }
    if (practice.maxDuration != null) {
      chips.add('Max ${practice.maxDuration!.inMinutes} min');
    }
    if (practice.graceFactor != null) {
      final gracePercent = (practice.graceFactor! * 100).round();
      chips.add('Grace +$gracePercent% window');
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          practice.icon,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          practice.getName(),
                          style: const TextStyle(
                            color: _midnight,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          practice.getDescription(),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      chips.map((meta) => _MetaChip(label: meta)).toList(),
                ),
              ),
              if (practice.highlights.isNotEmpty) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        practice.highlights
                            .map(
                              (highlight) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: _midnight,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        highlight,
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterInfoSheet extends StatelessWidget {
  final MasterGuide master;
  final Practice? specialPractice;
  final ScrollController controller;

  const _MasterInfoSheet({
    required this.master,
    required this.specialPractice,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: const EdgeInsets.only(top: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: master.gradient.colors.first,
                    child: Text(
                      master.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live with ${master.name}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          master.title,
                          style: const TextStyle(
                            color: _midnight,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black.withOpacity(0.03),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: master.gradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            master.description,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(
                                label: master.startTime,
                                inverted: true,
                              ),
                              _MetaChip(
                                label: '${master.duration.inMinutes} min session',
                                inverted: true,
                              ),
                              _MetaChip(
                                label: '${master.participantCount} joining',
                                inverted: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Master details',
                            style: TextStyle(
                              color: _midnight,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reserve your place ahead of the live ritual. Timings are locked to the master’s local dawn or noon windows.',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                              height: 1.4,
                            ),
                          ),
                          if (specialPractice != null) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Special master practice',
                              style: TextStyle(
                                color: _midnight,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SpecialPracticeCard(practice: specialPractice!),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialPracticeCard extends StatelessWidget {
  final Practice practice;

  const _SpecialPracticeCard({required this.practice});

  @override
  Widget build(BuildContext context) {
    final chips = [
      practice.availabilityLabel,
      practice.durationLabel,
      practice.requiresMaster ? 'Master-led' : 'Self-guided',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withOpacity(0.03),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(practice.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practice.getName(),
                      style: const TextStyle(
                        color: _midnight,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      practice.getDescription(),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map((meta) => _MetaChip(label: meta)).toList(),
          ),
        ],
      ),
    );
  }
}
