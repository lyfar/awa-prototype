part of 'package:awa_01_spark/practice/practice_journey_screen.dart';

class _PracticeTypeCard extends StatelessWidget {
  final Practice practice;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  const _PracticeTypeCard({
    required this.practice,
    required this.isSelected,
    required this.onTap,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isSelected ? _midnight : Colors.white;
    final textColor = isSelected ? Colors.white : _midnight;
    final description = practice.getDescription();
    final metaChips = <String>[
      practice.durationLabel,
      practice.availabilityLabel,
      practice.requiresMaster ? 'Master-led' : 'Self-guided',
      if (practice.hasCustomDuration) 'Custom duration',
    ];
    final highlight = practice.highlights.isNotEmpty ? practice.highlights.first : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: baseColor,
            border: Border.all(
              color:
                  isSelected
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.08),
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: _midnight.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        practice.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          practice.getName(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onInfo,
                    icon: Icon(
                      Icons.info_outline,
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.black.withOpacity(0.65),
                    ),
                    tooltip: 'Practice details',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: metaChips
                    .map(
                      (meta) => _MetaChip(
                        label: meta,
                        inverted: isSelected,
                      ),
                    )
                    .toList(),
              ),
              if (highlight != null) ...[
                const SizedBox(height: 12),
                Text(
                  highlight,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
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

class _MetaChip extends StatelessWidget {
  final String label;
  final bool inverted;

  const _MetaChip({required this.label, this.inverted = false});

  @override
  Widget build(BuildContext context) {
    final Color textColor = inverted ? Colors.white : _midnight;
    final Color background =
        inverted
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.05);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DurationProfile {
  final Duration duration;
  final String label;

  const _DurationProfile({
    required this.duration,
    required this.label,
  });
}

class _DurationOptionCard extends StatelessWidget {
  final _DurationProfile profile;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationOptionCard({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = isSelected ? _midnight : Colors.white;
    final Color borderColor =
        isSelected ? _midnight : Colors.black.withOpacity(0.08);
    final Color textColor = isSelected ? Colors.white : _midnight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 2),
            color: background,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  profile.label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.18)
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${profile.duration.inMinutes} min',
                  style: TextStyle(
                    color: isSelected ? Colors.white : _midnight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? badgeLabel;
  final IconData? icon;

  const _ModePill({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeLabel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isActive ? Colors.black : Colors.black54,
                  ),
                  const SizedBox(width: 6),
                ],
                _ModePillLabel(
                  label: label,
                  isActive: isActive,
                  badgeLabel: badgeLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModePillLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final String? badgeLabel;

  const _ModePillLabel({
    required this.label,
    required this.isActive,
    this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: TextStyle(
        color: isActive ? Colors.black : Colors.black54,
        fontWeight: FontWeight.w600,
      ),
    );
    if (badgeLabel == null) {
      return text;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        text,
        Positioned(
          top: -8,
          right: -18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeLabel!.toUpperCase(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MasterCard extends StatelessWidget {
  final MasterGuide master;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  const _MasterCard({
    required this.master,
    required this.onTap,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final stateWidgets = _buildStateContent(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: master.gradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: Text(
                    master.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        master.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'with ${master.name} • ${master.startTime}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MasterStateBadge(state: master.sessionState),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onInfo,
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...stateWidgets,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStateContent(BuildContext context) {
    switch (master.sessionState) {
      case MasterSessionState.upcoming:
        final countdown = _formatMasterCountdown(master.timeUntilStart);
        return [
          Text(
            'Begins in $countdown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add a reminder so you don’t miss this master practice window.',
            style: TextStyle(color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MasterCardActionButton(
                icon: Icons.event_available_outlined,
                label: 'Add to calendar',
                onPressed: () => debugPrint('Master calendar: ${master.id}'),
              ),
              _MasterCardActionButton(
                icon: Icons.notifications_active_outlined,
                label: 'Notify me',
                onPressed: () => debugPrint('Master notify: ${master.id}'),
              ),
            ],
          ),
        ];
      case MasterSessionState.lobby:
        final countdown = _formatMasterCountdown(master.timeUntilStart);
        return [
          _MasterCardPill(
            icon: Icons.hourglass_bottom,
            label: 'Doors unlock',
            value: countdown,
          ),
          const SizedBox(height: 12),
          const Text(
            'Lobby opens 5 min before the practice. Enter early and settle in.',
            style: TextStyle(color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 12),
          _MasterCardActionButton(
            icon: Icons.meeting_room_outlined,
            label: 'Enter lobby',
            onPressed: () => debugPrint('Master lobby: ${master.id}'),
            filled: true,
          ),
        ];
      case MasterSessionState.live:
        final remaining = master.timeRemaining;
        final label =
            remaining == null
                ? 'In progress'
                : '${_formatMasterCountdown(remaining)} left';
        return [
          _MasterCardPill(
            icon: Icons.radio_button_checked,
            label: 'Live now',
            value: label,
            accent: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(
            '${master.participantCount} souls currently in circle.',
            style: const TextStyle(color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 12),
          _MasterCardActionButton(
            icon: Icons.play_arrow_rounded,
            label: 'Join practice',
            onPressed: () => debugPrint('Master join: ${master.id}'),
            filled: true,
          ),
        ];
      case MasterSessionState.sealed:
        return [
          _MasterCardPill(
            icon: Icons.shield_moon_outlined,
            label: 'Circle sealed',
            value: 'Entry closed',
            accent: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Masters begin as a single heartbeat. After the first minute the ritual seals so the circle travels together.',
            style: TextStyle(color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 12),
          _MasterCardActionButton(
            icon: Icons.notifications_active_outlined,
            label: 'Subscribe for reminders',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('We\'ll nudge you before the next master window.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            filled: true,
          ),
        ];
    }
  }
}

class _MyPracticeCard extends StatelessWidget {
  final SavedPractice saved;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  const _MyPracticeCard({
    required this.saved,
    required this.isSelected,
    required this.onTap,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final practice = saved.practice;
    final Color baseColor = isSelected ? _midnight : Colors.white;
    final Color textColor = isSelected ? Colors.white : _midnight;
    final Color borderColor =
        isSelected ? Colors.transparent : Colors.black.withOpacity(0.08);
    final note = saved.note ?? practice.getDescription();
    final chips = <String>[
      '${saved.duration.inMinutes} min',
      practice.getTypeName(),
      _timestampLabel(saved.savedAt),
    ];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: _midnight.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        practice.icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          practice.getName(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note,
                          style: TextStyle(
                            color: textColor.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onInfo,
                    icon: Icon(
                      Icons.info_outline,
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map(
                      (chip) => _MetaChip(
                        label: chip,
                        inverted: isSelected,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timestampLabel(DateTime? savedAt) {
    if (savedAt == null) {
      return 'Pinned ritual';
    }
    final now = DateTime.now();
    final diff = now.difference(savedAt);
    if (diff.inMinutes < 60) {
      return 'Favourited ${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return 'Favourited ${diff.inHours}h ago';
    }
    return 'Favourited ${diff.inDays}d ago';
  }
}

class _MyModeLockedCard extends StatelessWidget {
  const _MyModeLockedCard();

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final benefits = const [
      'Pin any practice for instant access.',
      'Store preferred durations per ritual.',
      'Download masters + high-res audio.',
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF14141F), Color(0xFF2B2B3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: Colors.white70, size: 28),
          const SizedBox(height: 16),
          const Text(
            'Unlock My rituals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Premium members can bookmark their flow and rejoin in one tap.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(color: Colors.white70, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Subscription flow coming soon. Toggle paid flag in debug to preview.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Subscribe & unlock',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterStateBadge extends StatelessWidget {
  final MasterSessionState state;

  const _MasterStateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color color;
    switch (state) {
      case MasterSessionState.upcoming:
        label = 'Upcoming';
        color = Colors.white.withOpacity(0.2);
        break;
      case MasterSessionState.lobby:
        label = 'Lobby soon';
        color = Colors.white.withOpacity(0.25);
        break;
      case MasterSessionState.live:
        label = 'Live';
        color = Colors.redAccent;
        break;
      case MasterSessionState.sealed:
        label = 'Circle sealed';
        color = Colors.white.withOpacity(0.25);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: state == MasterSessionState.live ? Colors.white : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _MasterCardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  const _MasterCardActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: filled ? Colors.black : Colors.white,
        backgroundColor:
            filled ? Colors.white : Colors.white.withOpacity(0.18),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _MasterCardPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accent;

  const _MasterCardPill({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent ?? Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: accent ?? Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterStateDetailPanel extends StatelessWidget {
  final MasterGuide master;

  const _MasterStateDetailPanel({required this.master});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildBody(),
      ),
    );
  }

  List<Widget> _buildBody() {
    final subtle = TextStyle(color: _midnight.withOpacity(0.75), height: 1.35);
    switch (master.sessionState) {
      case MasterSessionState.upcoming:
        return [
          const _MasterDetailChip(label: 'Upcoming', color: Color(0xFFFFE5D3)),
          const SizedBox(height: 8),
          Text(
            'Scheduled for ${master.startTime}. Doors open 5 minutes before the ritual.',
            style: subtle,
          ),
          const SizedBox(height: 12),
          Text(
            'Add it to your calendar and enable a push reminder so you never miss the master window.',
            style: subtle,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MasterDetailButton(
                icon: Icons.event_available_outlined,
                label: 'Add to calendar',
                onPressed: () => debugPrint('Master calendar: ${master.id}'),
              ),
              _MasterDetailButton(
                icon: Icons.notifications_active_outlined,
                label: 'Notify me',
                onPressed: () => debugPrint('Master notify: ${master.id}'),
              ),
            ],
          ),
        ];
      case MasterSessionState.lobby:
        final countdown = _formatMasterCountdown(master.timeUntilStart);
        return [
          const _MasterDetailChip(label: 'Lobby opens', color: Color(0xFFE7E0FF)),
          const SizedBox(height: 8),
          Text(
            'Doors are unlocking. Practice begins in $countdown. Take a moment to settle in.',
            style: subtle,
          ),
          const SizedBox(height: 12),
          _MasterDetailCountdownTile(
            icon: Icons.lock_clock,
            label: 'Opens fully in',
            value: countdown,
          ),
          const SizedBox(height: 8),
          Text(
            'You can join now and wait with the circle until the audio starts.',
            style: subtle,
          ),
        ];
      case MasterSessionState.live:
        final remaining = master.timeRemaining;
        final remainingLabel =
            remaining == null
                ? 'In progress'
                : '${_formatMasterCountdown(remaining)} remaining';
        return [
          const _MasterDetailChip(label: 'Live now', color: Color(0xFFFFD9E7)),
          const SizedBox(height: 8),
          Text(
            '${master.participantCount} souls are already inside. Join whenever you’re ready.',
            style: subtle,
          ),
          const SizedBox(height: 12),
          _MasterDetailCountdownTile(
            icon: Icons.timelapse,
            label: 'Time left',
            value: remainingLabel,
          ),
        ];
      case MasterSessionState.sealed:
        return [
          const _MasterDetailChip(label: 'Circle sealed', color: Color(0xFFECE2FF)),
          const SizedBox(height: 8),
          Text(
            'Entry closed once the first minute passed so the circle could travel as one.',
            style: subtle,
          ),
          const SizedBox(height: 12),
          Text(
            'Subscribe to this master channel to get nudged before the next ritual.',
            style: subtle,
          ),
          const SizedBox(height: 12),
          _MasterDetailButton(
            icon: Icons.notifications_active_outlined,
            label: 'Subscribe for reminders',
            onPressed: () => debugPrint('Master subscribe: ${master.id}'),
          ),
        ];
    }
  }
}

class _MasterDetailChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MasterDetailChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _midnight,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MasterDetailButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MasterDetailButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _midnight,
        side: BorderSide(color: Colors.black.withOpacity(0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class _MasterDetailCountdownTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MasterDetailCountdownTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _midnight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _midnight.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: _midnight,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatMasterCountdown(Duration? duration) {
  if (duration == null) {
    return 'Soon';
  }
  if (duration.inHours >= 1) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }
  if (duration.inMinutes >= 1) {
    return '${duration.inMinutes}m';
  }
  return '${duration.inSeconds}s';
}
