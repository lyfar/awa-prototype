import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/meditation_models.dart';
import '../models/saved_practice.dart';
import '../home/home_demo_data.dart';
import '../soul/awa_sphere.dart';
import 'components/floating_icons_overlay.dart';
import 'components/practice_option_cards.dart';
import 'components/practice_selector_sheets.dart';
import 'practice_setup_screen.dart';

/// Practice selector screen - AwaSoul guided selection of practice type
/// Entry point to the practice flow from home screen
class PracticeSelectorScreen extends StatefulWidget {
  final bool isPaidUser;
  final VoidCallback? onUpgradeRequested;

  const PracticeSelectorScreen({
    super.key,
    this.isPaidUser = false,
    this.onUpgradeRequested,
  });

  @override
  State<PracticeSelectorScreen> createState() => _PracticeSelectorScreenState();
}

class _PracticeSelectorScreenState extends State<PracticeSelectorScreen> {
  int _selectedIndex = 0;
  int _selectedSavedIndex = 0;
  late List<PracticeTypeGroup> _groups;
  late List<SavedPractice> _savedPractices;
  bool _showingSaved = false;
  double _sphereEnergy = 0.0;

  // Pastel colors for practice icons
  static const List<Color> iconColors = [
    Color(0xFFE8B4A0), // Coral/peach
    Color(0xFFD4B8E8), // Lavender
    Color(0xFF9ED4E8), // Sky blue
    Color(0xFF8EDEC4), // Mint
    Color(0xFFE8A4B8), // Rose
    Color(0xFFE8D08C), // Golden
  ];

  @override
  void initState() {
    super.initState();
    print('PracticeSelectorScreen: Initializing practice selector');
    _groups = Practices.getGrouped();
    _savedPractices = List.of(HomeDemoData.savedPractices);
  }

  void _triggerEnergyBurst() {
    setState(() => _sphereEnergy = 0.15);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _sphereEnergy = 0.08);
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _sphereEnergy = 0.03);
    });
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) setState(() => _sphereEnergy = 0.0);
    });
  }

  void _selectPractice(int index) {
    if (_selectedIndex != index) {
      _triggerEnergyBurst();
    }
    setState(() => _selectedIndex = index);
  }

  void _selectSaved(int index) {
    if (_selectedSavedIndex != index) {
      _triggerEnergyBurst();
    }
    setState(() => _selectedSavedIndex = index);
  }

  void _continueToSetup() {
    if (_showingSaved) {
      final saved = _savedPractices[_selectedSavedIndex];
      print(
        'PracticeSelectorScreen: Starting saved practice ${saved.practice.getName()}',
      );
      final group = _groups.firstWhere(
        (g) => g.variants.any((p) => p.id == saved.practice.id),
        orElse: () => _groups.first,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => PracticeSetupScreen(
                practiceGroup: group,
                preselectedPractice: saved.practice,
                preselectedDuration: saved.duration,
              ),
        ),
      );
    } else {
      final selected = _groups[_selectedIndex];
      print(
        'PracticeSelectorScreen: Selected ${selected.displayName}, navigating to setup',
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PracticeSetupScreen(practiceGroup: selected),
        ),
      );
    }
  }

  void _switchToSaved() {
    if (!widget.isPaidUser) {
      print(
        'PracticeSelectorScreen: Free user tried to access Saved - showing premium sheet',
      );
      _showPremiumSheet();
      return;
    }
    setState(() => _showingSaved = true);
  }

  void _switchToPractices() {
    setState(() => _showingSaved = false);
  }

  void _showPremiumSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => PremiumUpgradeSheet(
            onUpgrade: () {
              Navigator.of(context).pop();
              widget.onUpgradeRequested?.call();
            },
            onClose: () => Navigator.of(context).pop(),
          ),
    );
  }

  void _showPracticeInfo(PracticeTypeGroup group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PracticeInfoSheet(group: group),
    );
  }

  void _showSavedInfo(SavedPractice saved) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SavedInfoSheet(saved: saved),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use standard sphere height for consistency across all screens
    const sphereHeight = AwaSphereConfig.standardHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTabBar()),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // AwaSphere with floating icons (only for Practices tab)
            if (!_showingSaved)
              SizedBox(
                height: sphereHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AwaSphereHeader(
                        height: sphereHeight,
                        interactive: true,
                        energy: _sphereEnergy,
                        primaryColor: const Color(0xFFFCB29C),
                        secondaryColor: const Color(0xFFE8D5D0),
                      ),
                    ),
                    Positioned.fill(
                      child: FloatingIconsOverlay(
                        groups: _groups,
                        selectedIndex: _selectedIndex,
                        onSelect: _selectPractice,
                        iconColors: iconColors,
                        getIcon: getPracticeIcon,
                      ),
                    ),
                  ],
                ),
              ),

            // Description text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Text(
                _showingSaved
                    ? 'Your favorite practices for quick access'
                    : 'These practices are here for you today. Choose one, or create your own.',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),

            // Cards section at bottom
            Expanded(
              flex: _showingSaved ? 6 : 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Expanded(
                      child:
                          _showingSaved
                              ? _buildSavedList()
                              : _buildPracticeList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child:
                          (!_showingSaved || _savedPractices.isNotEmpty)
                              ? _buildDynamicButton()
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTab('Practices', !_showingSaved, _switchToPractices),
            _buildTab(
              'Favorites',
              _showingSaved,
              _switchToSaved,
              showLock: !widget.isPaidUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    String label,
    bool isActive,
    VoidCallback onTap, {
    bool showLock = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.black87 : Colors.black45,
              ),
            ),
            if (showLock) ...[
              const SizedBox(width: 5),
              Icon(
                Icons.lock_outline,
                size: 13,
                color: isActive ? const Color(0xFFE88A6E) : Colors.black38,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicButton() {
    final selectedGroup = _groups[_selectedIndex];
    final buttonText = 'Choose ${selectedGroup.displayName}';
    final color = iconColors[_selectedIndex % iconColors.length];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: ElevatedButton(
        onPressed: _continueToSetup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeList() {
    return ListView.builder(
      itemCount: _groups.length,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemBuilder: (context, index) {
        final group = _groups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PracticeTypeOptionCard(
            group: group,
            isSelected: index == _selectedIndex,
            iconColor: iconColors[index % iconColors.length],
            onTap: () => _selectPractice(index),
            onInfoTap: () => _showPracticeInfo(group),
          ),
        );
      },
    );
  }

  Widget _buildSavedList() {
    if (_savedPractices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_outline, size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mark practices as favorites for quick access',
              style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _savedPractices.length,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemBuilder: (context, index) {
        final saved = _savedPractices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SavedPracticeOptionCard(
            saved: saved,
            isSelected: index == _selectedSavedIndex,
            iconColor: iconColors[index % iconColors.length],
            onTap: () => _selectSaved(index),
            onInfoTap: () => _showSavedInfo(saved),
          ),
        );
      },
    );
  }
}
