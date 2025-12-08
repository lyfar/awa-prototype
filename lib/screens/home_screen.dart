import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../services/practice_service.dart';
import '../services/language_service.dart';
import '../models/meditation_models.dart';
import '../home/components/profile_panel.dart';
import '../home/components/left_menu.dart';
import '../home/components/home_top_bar.dart';
import '../home/components/practice_canvas.dart';
import '../home/components/units_action_sheet.dart';
import '../home/components/story_carousel.dart';
import '../home/components/announcement_story_viewer.dart';
import '../home/theme/home_colors.dart';
import '../home/models/announcement_story.dart';
import '../home/models/home_section.dart';
import '../home/home_demo_data.dart';
import '../home/home_story_factory.dart';
import '../home/home_mission_service.dart';
import '../home/home_state_loader.dart';
import '../practice/practice_journey_screen.dart';
import '../practice/practice_session_screen.dart';
import '../practice/practice_feedback_screen.dart';
import '../practice/practice_selector_screen.dart';
import '../models/master_guide.dart';
import '../practice/master_session_screen.dart';
import '../home/pages/awaway_section.dart';
import '../home/pages/units_section.dart';
import '../home/pages/history_reactions_section.dart';
import '../home/pages/missions_section.dart';
import '../home/pages/faq_section.dart';
import '../globe/globe_widget.dart';
import '../globe/globe_states.dart';
import '../home/pages/invite_friend_screen.dart';
import '../missions/mission_models.dart';
import '../missions/mission_detail_sheet.dart';
import '../missions/mission_saved_pages_sheet.dart';
import '../models/saved_practice.dart';
import '../home/models/faq_item.dart';
import '../reactions/reaction_palette.dart';
import '../subscription/awa_journey_screen.dart';

part 'components/home_globe_view.dart';
part 'components/home_navigation.dart';
part 'components/home_sections.dart';
part 'components/home_start_button.dart';
part 'components/home_practice_helpers.dart';
part 'components/home_units_sheets.dart';
part 'components/home_profile_overlay.dart';
part 'components/home_mission_helpers.dart';
part 'components/home_summary_strip.dart';

const Color _spaceBlack = HomeColors.space;
const Color _eclipse = HomeColors.eclipse;
const Color _lilacMist = HomeColors.lavender;
const Color _emberPeach = HomeColors.peach;
const Color _canvasIvory = HomeColors.ivory;
const Color _sunriseCream = HomeColors.cream;
const Color _softRose = HomeColors.rose;
const LinearGradient _activeButtonGradient = LinearGradient(
  colors: [HomeColors.cream, HomeColors.peach],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const LinearGradient _globeOverlayGradient = LinearGradient(
  colors: [Color(0x55000000), Colors.transparent],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

/// Home screen with practice flow
///
/// This screen manages the complete practice journey:
/// 1. Home state - Shows globe and daily practice card
/// 2. Practice selection - Awa Soul guides user to choose practice
/// 3. Practice session - Audio player with controls
/// 4. Practice completion - Celebration and globe transition
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // User state
  bool _hasPracticedToday = false;
  double? _userLatitude;
  double? _userLongitude;
  bool _isLoading = true;

  // Practice flow state
  PracticeFlowState _practiceState = PracticeFlowState.home;
  Practice? _selectedPractice;

  // User profile state
  bool _showUserProfile = false;
  bool _showNavigationMenu = false;
  HomeSection _activeSection = HomeSection.home;

  // Mocked data for layout scaffolding
  int _currentStreak = 7;
  double _streakProgress = 0.55;
  final Map<PracticeType, List<String>> _practiceScripts =
      HomeDemoData.practiceScripts;
  final Map<PracticeType, List<Duration>> _durationOptions =
      HomeDemoData.durationOptions;
  bool _isPaidUser = false;
  static const int _practiceLumenReward = 15;
  PracticeType? _chosenPracticeType;
  Duration _selectedDuration = const Duration(minutes: 15);
  int _unitsBalance = 420;
  int _unitsEarnedThisWeek = 35;
  int _unitsSpentThisWeek = 12;
  final int _inviteRewardYou = 25;
  final int _inviteRewardFriend = 15;
  final String _inviteLink = 'https://awaterra.com/app/invite?code=AWA-SPARK';
  final String _inviteCode = 'AWA-SPARK';
  List<UnitTransaction> _unitsHistory = HomeDemoData.initialUnitHistory();
  double _awaPulseLevel = 0.78; // 0-1 scale representing global light
  int _activeLightUsers = 1842;
  int _awawayDay = 24;
  final int _awawayCycleLength = 42;
  double _awawayProgress = 0.57;
  final List<AwawayMilestone> _awawayMilestones = HomeDemoData.awawayMilestones;
  final List<PracticeHistoryEntry> _historyEntries =
      HomeDemoData.initialPracticeHistory();
  final List<ReactionStateData> _reactionStates = reactionTaxonomy;
  late List<AnnouncementStory> _stories;
  final List<MasterGuide> _masters = HomeDemoData.masterGuides;
  final List<SavedPractice> _savedPractices = List.of(
    HomeDemoData.savedPractices,
  );
  final List<FaqItem> _faqItems = HomeDemoData.faqItems;
  List<Mission> _missions = HomeDemoData.initialMissions();
  bool _hasNewMissionNotification = true;
  final Map<String, List<String>> _missionSavedPages = {
    'mission_alexandria': ['page_1', 'page_2'],
    'mission_sutra': ['page_1'],
    'mission_kulfi': ['page_1'],
  };
  List<Color> get _reactionPalette => _buildReactionPalette();
  int get _totalMindfulnessMinutes => _historyEntries.fold<int>(
    0,
    (sum, entry) => sum + entry.duration.inMinutes,
  );

  @override
  void initState() {
    super.initState();
    print('HomeScreen: Initializing home screen');
    _seedStories();

    _initializeHomeScreen();
  }

  /// Initialize home screen data
  Future<void> _initializeHomeScreen() async {
    print('HomeScreen: Loading initial data');

    try {
      final result = await loadHomeScreenState();
      print('HomeScreen: User practiced today: ${result.hasPracticed}');
      print(
        'HomeScreen: User location - lat: ${result.latitude}, lng: ${result.longitude}',
      );

      setState(() {
        _hasPracticedToday = result.hasPracticed;
        _userLatitude = result.latitude;
        _userLongitude = result.longitude;
        _isLoading = false;
      });

      print(
        'HomeScreen: Initialized - practiced: ${result.hasPracticed}, location: $_userLatitude, $_userLongitude',
      );
    } catch (e) {
      print('HomeScreen: ERROR during initialization: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Start the practice flow
  void _startPracticeFlow() {
    print('HomeScreen: Starting practice flow');
    setState(() {
      _practiceState = PracticeFlowState.practiceSelect;
    });
  }

  /// Complete the practice session
  Future<void> _completePractice({ReactionStateData? reaction}) async {
    print('HomeScreen: Completing practice session');

    setState(() {
      _practiceState = PracticeFlowState.completing;
    });

    try {
      // Save current location if not already saved
      if (_userLatitude == null || _userLongitude == null) {
        await PracticeService.saveCurrentLocation();
        final location = await PracticeService.getUserLocation();
        setState(() {
          _userLatitude = location['latitude'];
          _userLongitude = location['longitude'];
        });
      }

      // Mark practice as completed
      await PracticeService.markPracticeCompleted();

      // Wait for transition animation
      await Future.delayed(const Duration(milliseconds: 2000));

      setState(() {
        _hasPracticedToday = true;
        _practiceState = PracticeFlowState.home;
        _selectedPractice = null;
        _awaPulseLevel = (_awaPulseLevel + 0.02).clamp(0.0, 1.0);
        _activeLightUsers += 1;
      });

      print(
        'HomeScreen: Practice completed, user light should now appear on globe',
      );

      // Show completion feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reaction != null
                  ? 'Practice complete. Logged feeling: ${reaction.label}.'
                  : (LanguageService.getText('practice_completed') ??
                      'Practice completed! Your light now shines in the global community.'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green.withOpacity(0.8),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('HomeScreen: ERROR completing practice: $e');
      _exitPractice();
    }
  }

  /// Exit practice flow and return to home
  void _exitPractice() {
    print('HomeScreen: Exiting practice flow');
    setState(() {
      _practiceState = PracticeFlowState.home;
      _selectedPractice = null;
    });
  }

  void _onSectionSelected(HomeSection section, {bool fromProfile = false}) {
    if (section.isPaidFeature && !_isPaidUser) {
      if (!fromProfile) {
        setState(() {
          _showNavigationMenu = true;
        });
      }
      _openAwaJourneySheet(entryPoint: 'home_nav_${section.name}');
      return;
    }

    setState(() {
      _activeSection = section;
      if (section == HomeSection.missions) {
        _hasNewMissionNotification = false;
      }
      if (fromProfile) {
        _showUserProfile = false;
      }
    });

    if (!fromProfile) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        setState(() {
          _showNavigationMenu = false;
        });
      });
    }
  }

  void _handlePracticePrimaryAction() {
    if (_practiceState == PracticeFlowState.practiceSelect) {
      setState(() {
        _practiceState = PracticeFlowState.practicing;
      });
    } else if (_practiceState == PracticeFlowState.practicing) {
      _completePractice();
    }
  }

  void _togglePaidStatus(bool value) {
    setState(() {
      _isPaidUser = value;
    });
  }

  void _handleStreakPreviewChanged(int day) {
    int nextDay = day;
    if (nextDay < 1) {
      nextDay = 1;
    }
    if (nextDay > _awawayCycleLength) {
      nextDay = _awawayCycleLength;
    }
    final double normalized = (nextDay / _awawayCycleLength).clamp(0.0, 1.0);
    setState(() {
      _awawayDay = nextDay;
      _currentStreak = nextDay;
      _awawayProgress = normalized;
      _streakProgress = normalized;
    });
  }

  /// Open the new AwaSoul-guided practice selector flow
  Future<void> _openPracticeJourney() async {
    print('HomeScreen: Opening practice selector flow');
    _startPracticeFlow();

    // Navigate to the new AwaSoul-style practice selector
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: PracticeSelectorScreen(
              isPaidUser: _isPaidUser,
              onUpgradeRequested: () => _openAwaJourneySheet(entryPoint: 'practice_saved'),
            ),
          );
        },
      ),
    );

    // When returning, reset the practice state
    if (mounted) {
      setState(() {
        _practiceState = PracticeFlowState.home;
      });
    }
  }

  /// Legacy practice journey with drawer UI (kept for reference)
  Future<void> _openLegacyPracticeJourney() async {
    final practices = availablePracticeSummaries();
    if (practices.isEmpty) {
      return;
    }

    _startPracticeFlow();

    final selection = await Navigator.of(context).push<PracticeSelectionResult>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: PracticeJourneyScreen(
              practices: practices,
              durationOptions: _durationOptions,
              masters: _masters,
              savedPractices: _savedPractices,
              isPaidUser: _isPaidUser,
              reactionSnapshots: HomeDemoData.practiceReactionSnapshots,
              onUpgradeRequested:
                  () =>
                      _openAwaJourneySheet(entryPoint: 'lobby_saved_practice'),
            ),
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    if (selection == null) {
      setState(() {
        _practiceState = PracticeFlowState.home;
      });
      return;
    }

    if (selection.isMasterSelection) {
      final master = selection.master!;
      setState(() {
        _practiceState = PracticeFlowState.practicing;
      });
      final joined = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => MasterSessionScreen(master: master)),
      );
      setState(() {
        _practiceState = PracticeFlowState.home;
      });
      if (joined == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined ${master.title} with ${master.name}')),
        );
      }
      return;
    }

    if (selection.practice == null || selection.duration == null) {
      setState(() => _practiceState = PracticeFlowState.home);
      return;
    }

    final practice = selection.practice!;
    final practiceDuration = _clampDurationForPractice(
      practice,
      selection.duration!,
    );

    final proceed = await _showDoNotDisturbReminder(
      practice: practice,
      duration: practiceDuration,
    );
    if (!mounted) return;
    if (!proceed) {
      setState(() => _practiceState = PracticeFlowState.home);
      return;
    }

    setState(() {
      _chosenPracticeType = practice.type;
      _selectedDuration = practiceDuration;
      _selectedPractice = practice;
      _practiceState = PracticeFlowState.practicing;
    });

    final sessionCompleted = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: PracticeSessionScreen(
              practice: practice,
              duration: practiceDuration,
            ),
          );
        },
      ),
    );

    if (sessionCompleted == true) {
      final reaction = await Navigator.of(context).push<ReactionStateData>(
        MaterialPageRoute(
          builder: (_) => PracticeFeedbackScreen(practice: practice),
        ),
      );
      await _completePractice(reaction: reaction);
    } else {
      if (mounted) {
        setState(() {
          _practiceState = PracticeFlowState.home;
        });
      }
      _exitPractice();
    }
  }

  Future<bool> _showDoNotDisturbReminder({
    required Practice practice,
    required Duration duration,
  }) async {
    final minutes = duration.inMinutes;
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        return Container(
          margin: const EdgeInsets.only(top: 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 12 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _activeButtonGradient,
                        ),
                        child: const Icon(
                          Icons.notifications_off_outlined,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AwaSoul reminder',
                              style: TextStyle(
                                color: _spaceBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Switch to Do Not Disturb before you begin ${practice.getName()}.',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shield_moon_outlined,
                              size: 18,
                              color: _spaceBlack,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Silence for the next $minutes min',
                              style: const TextStyle(
                                color: _spaceBlack,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildReminderBullet(
                          'Slide down Control Center and tap Do Not Disturb / Focus.',
                        ),
                        _buildReminderBullet(
                          'Keep notifications quiet so the timer isn’t interrupted.',
                        ),
                        _buildReminderBullet(
                          'If you leave the app, we’ll remind you to return.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _spaceBlack,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'I’m in Do Not Disturb',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Widget _buildReminderBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.brightness_1, size: 8, color: _spaceBlack),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black.withOpacity(0.75),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMissionDetail(Mission mission) {
    setState(() => _hasNewMissionNotification = false);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D111F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder:
          (_) => MissionDetailSheet(
            mission: mission,
            currentBalance: _unitsBalance,
            onContribute: (multiplier) {
              Navigator.of(context).pop();
              _startMissionContribution(mission, multiplier);
            },
          ),
    );
  }

  void _startMissionContribution(Mission mission, int multiplier) {
    final requiredCost = mission.unitCost * multiplier;
    if (_unitsBalance < requiredCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Earn more Lumens to support this mission'),
        ),
      );
      return;
    }

    final result = applyMissionContribution(
      mission: mission,
      multiplier: multiplier,
      currentBalance: _unitsBalance,
      spentThisWeek: _unitsSpentThisWeek,
      history: _unitsHistory,
      missions: _missions,
    );

    setState(() {
      _unitsBalance = result.updatedBalance;
      _unitsSpentThisWeek = result.updatedSpent;
      _unitsHistory = result.updatedHistory;
      _missions = result.updatedMissions;
    });

    _showMissionFeedback(result.mission, result.pages, result.cost);
  }

  void _showMissionFeedback(Mission mission, int pages, int cost) {
    showMissionFeedbackDialog(
      context: context,
      mission: mission,
      pages: pages,
      cost: cost,
      remainingBalance: _unitsBalance,
      onViewSaved: () => _openSavedPagesView(mission),
    );
  }

  void _showEarnUnitsSheet() {
    showEarnUnitsSheet(
      context: context,
      hasPracticedToday: _hasPracticedToday,
      awawayDay: _awawayDay,
      awawayCycleLength: _awawayCycleLength,
      onPractice: _openPracticeJourney,
      onAwaway: () => _switchSection(HomeSection.streaks),
      onOfferings:
          () => _showComingSoonSnack(
            'Direct offerings will unlock in the next drop.',
          ),
    );
  }

  void _showSpendUnitsSheet() {
    final int minMissionCost =
        _missions.isEmpty
            ? 0
            : _missions.map((m) => m.unitCost).reduce((a, b) => a < b ? a : b);
    showSpendUnitsSheet(
      context: context,
      minMissionCost: minMissionCost,
      hasNewMissionNotification: _hasNewMissionNotification,
      isPaidUser: _isPaidUser,
      onSupportMissions: () => _switchSection(HomeSection.missions),
      onMasters:
          () => _showComingSoonSnack(
            'Master offerings unlock with the next collective.',
          ),
      onRepairAwaway: () => _switchSection(HomeSection.streaks),
      onDownloads: () {
        if (_isPaidUser) {
          _showComingSoonSnack('Downloads live in Profile ▸ Insider soon.');
        } else {
          _openAwaJourneySheet(entryPoint: 'downloads');
        }
      },
    );
  }

  void _openInviteFriendFlow() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => InviteFriendScreen(
              shareLink: _inviteLink,
              rewardYou: _inviteRewardYou,
              rewardFriend: _inviteRewardFriend,
              inviteCode: _inviteCode,
            ),
      ),
    );
  }

  void _showPulseDetails() {
    showPulseDrawer(context, (_awaPulseLevel * 100).round());
  }

  void _showLightUsersDetails() {
    showLightUsersDrawer(context, _activeLightUsers);
  }

  void _handleUrgentPracticeCall() {
    _openPracticeJourney();
  }

  void _handleUrgentDonate() {
    _switchSection(HomeSection.units);
    _showSpendUnitsSheet();
  }

  bool get _showMiniStart =>
      _practiceState == PracticeFlowState.home &&
      _activeSection != HomeSection.home &&
      !_showNavigationMenu &&
      !_showUserProfile;

  void _handleMiniStartTap() {
    setState(() {
      _activeSection = HomeSection.home;
      _showNavigationMenu = false;
    });
  }

  void _handleMiniStartLongPress() {
    if (_practiceState == PracticeFlowState.home) {
      _openPracticeJourney();
    }
  }

  void _openSavedPagesView(Mission mission) {
    final pages = _missionSavedPages[mission.id] ?? ['page_1'];
    showMissionSavedPagesSheet(
      context: context,
      mission: mission,
      pageAssets: pages,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      'HomeScreen: Building UI - practiceState: ${_practiceState.name}, isLoading: $_isLoading',
    );

    return Scaffold(
      backgroundColor: _canvasIvory,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + (_showMiniStart ? 110 : 0),
              ),
              child: Column(
                children: [
                  HomeTopBar(
                    isMenuOpen: _showNavigationMenu,
                    onMenuTap: _toggleNavigationMenu,
                    onProfileTap: _toggleProfilePanel,
                    stories: _stories,
                    onStorySelected: _handleStorySelected,
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildCenterStage()),
                ],
              ),
            ),
          ),

          HomeProfileOverlay(
            isVisible: _showUserProfile,
            onClose: () {
              setState(() {
                _showUserProfile = false;
              });
            },
            hasPracticedToday: _hasPracticedToday,
            userLatitude: _userLatitude,
            userLongitude: _userLongitude,
            reactionPalette: _reactionPalette,
            totalMindfulnessMinutes: _totalMindfulnessMinutes,
            activeSection: _activeSection,
            onSectionSelected:
                (section) => _onSectionSelected(section, fromProfile: true),
            practiceState: _practiceState,
            onPracticeStateChanged: (practiced) {
              setState(() {
                _hasPracticedToday = practiced;
              });
            },
            isPaidUser: _isPaidUser,
            onPaidStatusChanged: _togglePaidStatus,
            awawayDay: _awawayDay,
            awawayCycleLength: _awawayCycleLength,
            onAwawayDayChanged: _handleStreakPreviewChanged,
            streakProgress: _streakProgress,
            unitsBalance: _unitsBalance,
            unitsEarnedThisWeek: _unitsEarnedThisWeek,
            unitsSpentThisWeek: _unitsSpentThisWeek,
            historyPracticeCount: _historyEntries.length,
            historyReactionCount:
                _historyEntries
                    .where((entry) => entry.reactionKey != null)
                    .length,
            savedCount: _savedPractices.length,
            onUpgradeTapped: () => _openAwaJourneySheet(entryPoint: 'profile'),
          ),

          _buildNavigationOverlay(),
          _buildFloatingStartButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingStartButton() {
    if (!_showMiniStart) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 16 + MediaQuery.of(context).padding.bottom,
      child: Center(
        child: GestureDetector(
          onTap: _handleMiniStartTap,
          onLongPress: _handleMiniStartLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _activeButtonGradient,
              boxShadow: [
                BoxShadow(
                  color: _emberPeach.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: _spaceBlack,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationOverlay() {
    return IgnorePointer(
      ignoring: !_showNavigationMenu,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.05, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        child:
            !_showNavigationMenu
                ? const SizedBox.shrink()
                : HomeNavigationOverlay(
                  onClose: () {
                    setState(() {
                      _showNavigationMenu = false;
                    });
                  },
                  child: LeftMenu(
                    activeSection: _activeSection,
                    onSectionSelected: _onSectionSelected,
                    isPaidUser: _isPaidUser,
                    newMissionCount: _hasNewMissionNotification ? 1 : 0,
                    awaPulseLevel: _awaPulseLevel,
                    lightCarriers: _activeLightUsers,
                    unitsSpentThisWeek: _unitsSpentThisWeek,
                    missionsTotal: _missions.length,
                    missionPagesRestored: _missions.fold<int>(
                      0,
                      (sum, mission) => sum + mission.userPages,
                    ),
                    faqCount: _faqItems.length,
                    onClose: () {
                      setState(() {
                        _showNavigationMenu = false;
                      });
                    },
                  ),
                ),
      ),
    );
  }

  void _toggleNavigationMenu() {
    setState(() {
      _showNavigationMenu = !_showNavigationMenu;
    });
  }

  void _toggleProfilePanel() {
    setState(() {
      _showUserProfile = !_showUserProfile;
    });
  }

  List<Color> _buildReactionPalette() {
    if (_reactionStates.isEmpty) return [];

    final Map<String, int> counts = {};
    for (final entry in _historyEntries) {
      final key = entry.reactionKey;
      if (key == null) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final List<MapEntry<String, int>> sorted =
        counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final List<Color> colors = [];
    for (final entry in sorted) {
      try {
        final match = _reactionStates.firstWhere(
          (reaction) => reaction.key == entry.key,
        );
        colors.add(match.color);
      } catch (_) {
        // ignore missing reaction keys
      }
      if (colors.length >= 5) break;
    }

    if (colors.isEmpty) {
      colors.addAll(_reactionStates.take(4).map((r) => r.color));
    }

    return colors;
  }

  Duration _clampDurationForPractice(Practice practice, Duration duration) {
    var result = duration;
    final min = practice.minDuration;
    final max = practice.maxDuration;
    if (min != null && result < min) {
      result = min;
    }
    if (max != null && result > max) {
      result = max;
    }
    return result;
  }

  void _showPremiumSnack() {
    _openAwaJourneySheet(entryPoint: 'snackbar');
  }

  Future<void> _openAwaJourneySheet({String entryPoint = 'generic'}) async {
    if (!mounted) return;
    print('HomeScreen: Opening AWA Journey screen from $entryPoint');
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AwaJourneyScreen(
          isCurrentlySubscribed: _isPaidUser,
          onSubscribed: () {
            if (mounted) {
              setState(() {
                _isPaidUser = true;
              });
            }
          },
        ),
      ),
    );
  }

  void _showComingSoonSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: _eclipse,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _contactSupportTeam() {
    _showComingSoonSnack(
      'We will connect you with a guide shortly. Live chat arrives next build.',
    );
  }

  void _showAppUpdateHighlights() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final entries = [
          'Fresh Lobby tabs: Masters + Favourites.',
          'Push notification settings inside the profile drawer.',
          'Favourites tab lets members pin preferred flows.',
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 30,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'What’s new',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: _lilacMist,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry,
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _lilacMist,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _promptFeedbackStory() async {
    final controller = TextEditingController();
    final feedback = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 26,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Share your suggestions',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us which rituals or features you want next. We’ll award +10 Lumens for thoughtful feedback.',
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  minLines: 3,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your ideas...',
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, __) {
                    final canSubmit = value.text.trim().length >= 6;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            canSubmit
                                ? () =>
                                    Navigator.of(context).pop(value.text.trim())
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _emberPeach,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Send & earn Lumens'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    if (!mounted) return;
    if (feedback != null && feedback.trim().isNotEmpty) {
      setState(() {
        _unitsBalance += 10;
        _unitsEarnedThisWeek += 10;
      });
      _showComingSoonSnack('Thank you! +10 Lumens added for your insight.');
    }
  }

  void _switchSection(HomeSection section) {
    setState(() {
      _activeSection = section;
      if (section == HomeSection.missions) {
        _hasNewMissionNotification = false;
      }
      _showNavigationMenu = false;
    });
  }

  Widget _buildCenterStage() {
    final bool canStartPractice =
        _activeSection == HomeSection.home &&
        _practiceState == PracticeFlowState.home;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child:
                _activeSection == HomeSection.home
                    ? _buildExperienceSurface()
                    : _buildSectionContent(_activeSection),
          ),
        ),
        if (canStartPractice) ...[
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: HomeMiniSummaryCard(
                  label: 'AWA pulse',
                  value: '${(_awaPulseLevel * 100).round()}%',
                  onTap: _showPulseDetails,
                  accent: _lilacMist,
                ),
              ),
              const SizedBox(width: 16),
              HomeStartButton(
                isEnabled: canStartPractice,
                hasPracticedToday: _hasPracticedToday,
                onPressed: _openPracticeJourney,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HomeMiniSummaryCard(
                  label: 'Light carriers',
                  value: formatLightUsers(_activeLightUsers),
                  onTap: _showLightUsersDetails,
                  accent: _emberPeach,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildSectionContent(HomeSection section) {
    switch (section) {
      case HomeSection.streaks:
        return AwawaySection(
          currentDay: _awawayDay,
          cycleLength: _awawayCycleLength,
          progress: _awawayProgress,
          milestones: _awawayMilestones,
          canRepair: true,
        );
      case HomeSection.units:
        return UnitsSection(
          balance: _unitsBalance,
          earnedThisWeek: _unitsEarnedThisWeek,
          spentThisWeek: _unitsSpentThisWeek,
          history: _unitsHistory,
          onEarnUnits: _showEarnUnitsSheet,
          onSpendUnits: _showSpendUnitsSheet,
          onInviteFriend: _openInviteFriendFlow,
          inviteRewardYou: _inviteRewardYou,
          inviteRewardFriend: _inviteRewardFriend,
        );
      case HomeSection.missions:
        return MissionsSection(
          missions: _missions,
          onMissionSelected: _openMissionDetail,
          onContribute: _openMissionDetail,
        );
      case HomeSection.history:
        return ReactionHistorySection(
          entries: _historyEntries,
          taxonomy: _reactionStates,
          isPaidUser: _isPaidUser,
          onUpgradeRequested: () => _openAwaJourneySheet(entryPoint: 'insider_reactions'),
        );
      case HomeSection.faq:
        return FaqSection(items: _faqItems, onContact: _contactSupportTeam);
      default:
        return HomeSectionPlaceholder(section: section);
    }
  }

  void _seedStories() {
    _stories = buildHomeStories(
      onMissionCta: () => _switchSection(HomeSection.missions),
      onPracticeCta: _openPracticeJourney,
      onMasterCta:
          () => _showComingSoonSnack(
            'Masters hub is unlocking next prototype drop.',
          ),
      onUpdateCta: _showAppUpdateHighlights,
      onFeedbackCta: _promptFeedbackStory,
      onUrgentJoinCta: _handleUrgentPracticeCall,
      onUrgentDonateCta: _handleUrgentDonate,
    );
  }

  void _handleStorySelected(AnnouncementStory story) {
    setState(() {
      story.isNew = false;
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (_, __, ___) => AnnouncementStoryViewer(
              stories: _stories,
              initialIndex: _stories.indexOf(story),
            ),
      ),
    );
  }

  Widget _buildExperienceSurface() {
    final isPracticeFlow = _practiceState != PracticeFlowState.home;
    return Stack(
      fit: StackFit.expand,
      children: [
        HomeGlobeView(
          isLoading: _isLoading,
          userLatitude: _userLatitude,
          userLongitude: _userLongitude,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child:
              isPracticeFlow
                  ? Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 0.92,
                      heightFactor: 0.9,
                      child: Container(
                        key: ValueKey('practice-${_practiceState.name}'),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 24,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: PracticeCanvas(
                          title: practiceCanvasHeadline(_practiceState),
                          subtitle: practiceCanvasDescription(_practiceState),
                          scriptLines: practiceScriptFor(
                            chosenType: _chosenPracticeType,
                            selectedPractice: _selectedPractice,
                            scripts: _practiceScripts,
                          ),
                          metaChips: _practiceMetaChips(),
                          primaryLabel: _primaryActionLabel(),
                          isPrimaryEnabled: _canTriggerPrimaryAction(),
                          onPrimary:
                              _canTriggerPrimaryAction()
                                  ? _handlePracticePrimaryAction
                                  : null,
                          onBack:
                              _practiceState == PracticeFlowState.completing
                                  ? null
                                  : _exitPractice,
                          disableSoulInteraction: _showUserProfile,
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  bool _canTriggerPrimaryAction() {
    final bool actionable =
        _practiceState == PracticeFlowState.practiceSelect ||
        _practiceState == PracticeFlowState.practicing;
    return actionable && _practiceState != PracticeFlowState.completing;
  }

  String _primaryActionLabel() {
    switch (_practiceState) {
      case PracticeFlowState.practiceSelect:
        return 'Begin session';
      case PracticeFlowState.practicing:
        return 'Complete practice';
      case PracticeFlowState.completing:
        return 'Completing...';
      case PracticeFlowState.home:
        return 'Begin session';
    }
  }

  List<PracticeMetaChipData> _practiceMetaChips() {
    final practice = _selectedPractice;
    final typeLabel = practice?.getTypeName() ?? 'Custom practice';
    final durationLabel = '${_selectedDuration.inMinutes} min';
    return [
      PracticeMetaChipData(icon: Icons.self_improvement, label: typeLabel),
      PracticeMetaChipData(icon: Icons.timer, label: durationLabel),
    ];
  }

  Widget _buildStartButton() {
    final bool disableButton =
        _practiceState != PracticeFlowState.home ||
        _activeSection != HomeSection.home;
    final title = LanguageService.getText('begin_session') ?? 'Start Practice';
    final subtitle =
        _hasPracticedToday
            ? 'Light ignited today'
            : 'Guided meditation with AWA Soul';

    return Opacity(
      opacity: disableButton ? 0.45 : 1,
      child: SizedBox(
        width: 220,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: _activeButtonGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _emberPeach.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: disableButton ? null : _openPracticeJourney,
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.transparent,
              foregroundColor: _spaceBlack,
              disabledForegroundColor: _spaceBlack,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
