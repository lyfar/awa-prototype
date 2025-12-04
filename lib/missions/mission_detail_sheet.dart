import 'package:flutter/material.dart';

import 'mission_models.dart';

class MissionDetailSheet extends StatefulWidget {
  final Mission mission;
  final int currentBalance;
  final ValueChanged<int> onContribute; // multiplier

  const MissionDetailSheet({
    super.key,
    required this.mission,
    required this.currentBalance,
    required this.onContribute,
  });

  @override
  State<MissionDetailSheet> createState() => _MissionDetailSheetState();
}

class _MissionDetailSheetState extends State<MissionDetailSheet> {
  final List<int> _multipliers = [1, 2, 3, 5];
  int _selectedMultiplier = 1;

  @override
  Widget build(BuildContext context) {
    final cost = widget.mission.unitCost * _selectedMultiplier;
    final pages = widget.mission.pagesPerContribution * _selectedMultiplier;
    final canAfford = widget.currentBalance >= cost;

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 40, spreadRadius: 10),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: viewInsets + 24,
                top: 12,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildContributionConsole(cost, pages),
                  const SizedBox(height: 32),
                  _buildActionArea(canAfford, cost),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00F0FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
          ),
          child: const Text(
            'INITIATING TRANSFER',
            style: TextStyle(
              color: Color(0xFF00F0FF),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.mission.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Contribution channel open. Select power output.',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildContributionConsole(int cost, int pages) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POWER LEVEL',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${_selectedMultiplier}x BOOST',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _multipliers.map((m) {
                final bool isSelected = _selectedMultiplier == m;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMultiplier = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${m}x',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OUTPUT',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pages Pages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COST',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cost Lumens',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(bool canAfford, int cost) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                canAfford ? () => widget.onContribute(_selectedMultiplier) : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor:
                  canAfford ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.1),
              foregroundColor: Colors.black,
              elevation: canAfford ? 8 : 0,
              shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              canAfford ? 'CONFIRM TRANSFER' : 'INSUFFICIENT LUMENS',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 1.0,
                color: canAfford ? Colors.black : Colors.white38,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!canAfford)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Get more Lumens',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          )
        else
          Text(
            'Balance after: ${widget.currentBalance - cost} Lumens',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
      ],
    );
  }
}
