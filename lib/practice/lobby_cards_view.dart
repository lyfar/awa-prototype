import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../home/theme/home_colors.dart';
import '../../models/master_guide.dart';
import '../../models/meditation_models.dart';
import '../../models/saved_practice.dart';
import '../reactions/reaction_palette.dart';

enum LobbyTab { practices, saved }

class LobbyCardItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Practice? practice;
  final MasterGuide? master;
  final SavedPractice? savedPractice;
  final bool isMaster;
  final Map<String, int>? reactionCounts;

  LobbyCardItem.practice(this.practice, this.reactionCounts)
      : id = 'practice_${practice!.id}',
        title = practice.getName(),
        subtitle = practice.durationLabel,
        description = practice.getDescription(),
        color = HomeColors.cream,
        master = null,
        savedPractice = null,
        isMaster = false;

  LobbyCardItem.master(this.master)
      : id = 'master_${master!.id}',
        title = master.title,
        subtitle = 'Live with ${master.name}',
        description = master.description,
        color = HomeColors.lavender,
        practice = null,
        savedPractice = null,
        isMaster = true,
        reactionCounts = null;

  LobbyCardItem.saved(this.savedPractice, Map<String, int>? reactions)
      : id = 'saved_${savedPractice!.id}',
        title = savedPractice.practice.getName(),
        subtitle = '${savedPractice.duration.inMinutes} Min • Custom',
        description = savedPractice.note ?? savedPractice.practice.getDescription(),
        color = HomeColors.peach,
        practice = null,
        master = null,
        isMaster = false,
        reactionCounts = reactions;
}

class LobbyCardsView extends StatefulWidget {
  final List<Practice> practices;
  final List<MasterGuide> masters;
  final List<SavedPractice> savedPractices;
  final Function(dynamic item) onItemSelected;
  final bool isPaidUser;
  final Map<String, Map<String, int>> reactionSnapshots;

  const LobbyCardsView({
    super.key,
    required this.practices,
    required this.masters,
    required this.savedPractices,
    required this.onItemSelected,
    required this.isPaidUser,
    this.reactionSnapshots = const {},
  });

  @override
  State<LobbyCardsView> createState() => _LobbyCardsViewState();
}

class _LobbyCardsViewState extends State<LobbyCardsView> {
  LobbyTab _currentTab = LobbyTab.practices;
  int _selectedIndex = 0;
  bool _isExpanded = false;

  List<LobbyCardItem> get _items {
    if (_currentTab == LobbyTab.practices) {
      return [
        ...widget.masters.map((m) => LobbyCardItem.master(m)),
        ...widget.practices.map(
          (p) => LobbyCardItem.practice(
            p,
            widget.reactionSnapshots[p.id],
          ),
        ),
      ];
    } else {
      if (!widget.isPaidUser) return [];
      return widget.savedPractices
          .map(
            (s) => LobbyCardItem.saved(
              s,
              widget.reactionSnapshots[s.practice.id],
            ),
          )
          .toList();
    }
  }

  @override
  void didUpdateWidget(covariant LobbyCardsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isPaidUser && _currentTab == LobbyTab.saved) {
      setState(() {
        _currentTab = LobbyTab.practices;
        _selectedIndex = 0;
        _isExpanded = false;
      });
    }
  }

  void _handleTap(int index) {
    if (_selectedIndex == index) {
      // If tapping the selected card, toggle expansion
      setState(() {
        _isExpanded = !_isExpanded;
      });
    } else {
      // If tapping a background card, select it (and collapse if expanded)
      setState(() {
        _selectedIndex = index;
        _isExpanded = false;
      });
    }
  }

  void _triggerSelection(LobbyCardItem item) {
    if (item.practice != null) {
      widget.onItemSelected(item.practice);
    } else if (item.master != null) {
      widget.onItemSelected(item.master);
    } else if (item.savedPractice != null) {
      widget.onItemSelected(item.savedPractice);
    }
  }

  void _handleVerticalSwipe(double velocity) {
    if (_isExpanded) return; // Disable swipe when expanded
    
    final items = _items;
    if (items.isEmpty) return;

    if (velocity < -500) {
      // Swipe Up -> Next
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % items.length;
      });
    } else if (velocity > 500) {
      // Swipe Down -> Previous
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + items.length) % items.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final safeIndex = items.isEmpty
        ? 0
        : _selectedIndex.clamp(0, items.length - 1);
    
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Define zones
              final double totalHeight = constraints.maxHeight;
              final double bubblesHeight = totalHeight * 0.35;
              final double cardsTop = bubblesHeight; // Cards start below bubbles
              
              return GestureDetector(
                onVerticalDragEnd: (details) => _handleVerticalSwipe(details.primaryVelocity ?? 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Flying Shapes Area
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutQuart,
                      top: _isExpanded ? -200 : 0, // Move out when expanded
                      left: 0,
                      right: 0,
                      height: bubblesHeight,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isExpanded ? 0.0 : 1.0,
                        child: items.isEmpty 
                          ? const SizedBox.shrink()
                          : _FlyingShapes(
                              items: items,
                              selectedIndex: safeIndex,
                              onShapeTap: (index) {
                                 setState(() {
                                   _selectedIndex = index;
                                   _isExpanded = false;
                                 });
                              },
                            ),
                      ),
                    ),
                    
                    // Card Stack Area
                    Positioned.fill(
                      top: 0, // Use full height for stack positioning calculations
                      child: items.isEmpty
                          ? _buildEmptyState()
                          : _CardWalletStack(
                              items: items,
                              selectedIndex: safeIndex,
                              isExpanded: _isExpanded,
                              availableHeight: totalHeight,
                              cardsStartTop: cardsTop,
                              onCardTap: _handleTap,
                              onCollapse: () => setState(() => _isExpanded = false),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (!_isExpanded) // Hide bottom bar when expanded
          _buildBottomBar(items.isEmpty ? null : items[safeIndex]),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmarks_outlined, size: 48, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            _currentTab == LobbyTab.saved
                ? 'No favourites yet'
                : 'No practices available',
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TabPill(
                      label: 'Practices',
                      isActive: _currentTab == LobbyTab.practices,
                      onTap: () => setState(() {
                        _currentTab = LobbyTab.practices;
                        _selectedIndex = 0;
                        _isExpanded = false;
                      }),
                    ),
                    _TabPill(
                      label: 'Favourites',
                      isActive: _currentTab == LobbyTab.saved,
                      onTap: () {
                        if (!widget.isPaidUser) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Favourites are for Premium members. Upgrade to access your picks.',
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _currentTab = LobbyTab.saved;
                          _selectedIndex = 0;
                          _isExpanded = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomBar(LobbyCardItem? selectedItem) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedItem == null 
              ? null 
              : () => _triggerSelection(selectedItem),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              selectedItem == null ? 'Choose Practice' : 'Choose ${selectedItem.title}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? HomeColors.rose : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _FlyingShapes extends StatefulWidget {
  final List<LobbyCardItem> items;
  final int selectedIndex;
  final ValueChanged<int> onShapeTap;

  const _FlyingShapes({
    required this.items,
    required this.selectedIndex,
    required this.onShapeTap,
  });

  @override
  State<_FlyingShapes> createState() => _FlyingShapesState();
}

class _FlyingShapesState extends State<_FlyingShapes> with TickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight * 0.5);
        final double radius = math.min(constraints.maxWidth, constraints.maxHeight) * 0.35;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
             // Helper text
            Positioned(
              top: center.dy + radius + 40,
              left: 24,
              right: 24,
              child: const Text(
                'These practices are here for you today.\nChoose one, or create your own.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            for (int i = 0; i < widget.items.length; i++)
               _AnimatedBubble(
                 index: i,
                 item: widget.items[i],
                 isSelected: i == widget.selectedIndex,
                 center: center,
                 radius: radius,
                 totalItems: widget.items.length,
                 floatAnimation: _floatController,
                 onTap: () => widget.onShapeTap(i),
               ),
          ],
        );
      },
    );
  }
}

class _AnimatedBubble extends StatelessWidget {
  final int index;
  final LobbyCardItem item;
  final bool isSelected;
  final Offset center;
  final double radius;
  final int totalItems;
  final Animation<double> floatAnimation;
  final VoidCallback onTap;

  const _AnimatedBubble({
    required this.index,
    required this.item,
    required this.isSelected,
    required this.center,
    required this.radius,
    required this.totalItems,
    required this.floatAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Distribute bubbles
    double targetDx = 0;
    double targetDy = 0;
    
    if (index == 0) {
       targetDx = 0;
       targetDy = 0;
    } else if (index <= 6) {
       final angle = (index - 1) * (math.pi / 3) - (math.pi / 2);
       targetDx = radius * math.cos(angle);
       targetDy = radius * math.sin(angle);
    } else {
       final angle = (index - 7) * (math.pi / 4); 
       targetDx = radius * 1.7 * math.cos(angle);
       targetDy = radius * 1.7 * math.sin(angle);
    }
    
    final double size = isSelected ? 72.0 : 56.0;
    final randomSeed = (index * 13.0); 
    
    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        final floatVal = math.sin((floatAnimation.value * 2 * math.pi) + randomSeed);
        final floatOffset = Offset(
           floatVal * 5.0, 
           math.cos((floatAnimation.value * 2 * math.pi) + randomSeed) * 5.0, 
        );
        
        return Positioned(
          left: center.dx + targetDx - size / 2 + floatOffset.dx,
          top: center.dy + targetDy - size / 2 + floatOffset.dy,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: item.color.withOpacity(isSelected ? 1.0 : 0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: item.color.withOpacity(0.6),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  if (!isSelected)
                     BoxShadow(
                      color: item.color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
                border: isSelected 
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardWalletStack extends StatelessWidget {
  final List<LobbyCardItem> items;
  final int selectedIndex;
  final bool isExpanded;
  final double availableHeight;
  final double cardsStartTop;
  final ValueChanged<int> onCardTap;
  final VoidCallback onCollapse;

  const _CardWalletStack({
    required this.items,
    required this.selectedIndex,
    required this.isExpanded,
    required this.availableHeight,
    required this.cardsStartTop,
    required this.onCardTap,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    // If expanded, we just show the selected card big on top
    // and maybe the others faded out behind or below.
    
    final int visibleCount = math.min(items.length, 7);
    
    // We need indices: [selected+6 ... selected] 
    // Drawn order: fursthest first.
    
    final List<int> indicesToDraw = [];
    if (isExpanded) {
      // If expanded, draw others then selected on top
      for (int i = 0; i < items.length; i++) {
        if (i != selectedIndex) indicesToDraw.add(i);
      }
      indicesToDraw.add(selectedIndex); // Selected last (on top)
    } else {
      // If stack, draw reverse order relative to selected
      for (int i = visibleCount - 1; i >= 0; i--) {
        indicesToDraw.add((selectedIndex + i) % items.length);
      }
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: indicesToDraw.map((index) {
        int dist = (index - selectedIndex + items.length) % items.length;
        return _buildCard(context, index, dist);
      }).toList(),
    );
  }

  Widget _buildCard(BuildContext context, int index, int dist) {
    final item = items[index];
    final bool hasReactions =
        item.reactionCounts != null &&
        item.reactionCounts!.values.any((count) => count > 0);
    // Key is crucial for the shuffle animation to track the widget as it moves in the stack
    final Key cardKey = ValueKey(item.id);
    
    // Layout logic:
    // Base Top is cardsStartTop.
    // We stack UPWARDS from base.
    // Highest card (dist=0) is at the BOTTOM of the visual stack (physically lowest Y).
    // Wait, no. We want the Selected Card (dist 0) to be in FRONT and LOWER than the headers behind it.
    
    // Upward Stack:
    // Card 0 (Front): Y = Base + (visibleCount * offset) ? No.
    // Let's say BaseY = cardsStartTop.
    // We want the headers of cards 1, 2, 3... to be visible ABOVE Card 0.
    // So Card 3 is at Top. Card 2 is Top + Offset. Card 1 is Top + 2*Offset. Card 0 is Top + 3*Offset.
    
    // Let's define the visual Top for the Furthest Visible Card.
    // It should be at cardsStartTop.
    
    final double collapsedHeight = 220;
    final double expandedHeight = availableHeight * 0.85;
    final double headerOffset = 55.0;
    
    // Calculate target Top
    double top;
    double height;
    double opacity;
    
    if (isExpanded) {
      if (dist == 0) {
        // Selected Expanded
        top = availableHeight * 0.05; // Near top
        height = expandedHeight;
        opacity = 1.0;
      } else {
        // Others hidden
        top = availableHeight;
        height = collapsedHeight;
        opacity = 0.0;
      }
    } else {
      // Collapsed Stack
      // We want Card 0 at the bottom of the stack group.
      // Max visible dist is ~6.
      // Card 6 is at cardsStartTop.
      // Card 0 is at cardsStartTop + (6 * headerOffset).
      
      // Wait, `dist` is 0 for selected.
      // We want to reverse mapping for Y position.
      // visibleCount is 7. Max dist is 6.
      // We want dist 6 to be at Top.
      // dist 0 to be at Top + (6 * Offset).
      
      // Limit dist to visible count for calc
      // Reverse it: 0 is bottom (highest Y), 6 is top (lowest Y)
      // Actually we want dist 0 to be the "Front" card.
      // In an upward stack (headers visible), the Front card is at the BOTTOM.
      // So Y increases as dist decreases? No.
      // Card at back (dist 6) is at Y=0.
      // Card at front (dist 0) is at Y=300.
      // So Y = Start + (MaxDist - dist) * Offset?
      // No, visual order:
      // Top of screen
      // | Card 6 Header
      // | Card 5 Header
      // ...
      // | Card 0 Header & Body
      // Bottom
      
      // So Card 6 Y < Card 5 Y < ... < Card 0 Y.
      // Yes.
      // Y = cardsStartTop + ((6 - dist) * headerOffset).
      // But we only show 7 cards. 
      // Let's use a fixed MaxDist = 6.
      
      // Wait, `dist` logic:
      // selectedIndex = 0. index = 0. dist = 0.
      // selectedIndex = 0. index = 6. dist = 6.
      
      // We want dist 6 at Top.
      // dist 0 at Bottom.
      
      // BUT, if we have fewer than 7 cards?
      // Adjust maxDist to items.length - 1.
      // Actually, max dist is determined by how many cards we have.
      // Let's say we have 3 cards.
      // Card 2 (Back) -> Top.
      // Card 0 (Front) -> Top + 2*Offset.
      
      // So Y = cardsStartTop + ((actualMax - dist) * headerOffset).
      
      final int actualMax = math.min(items.length - 1, 6);
      
      double relativePos = (actualMax - dist).toDouble();
      // If dist > actualMax (hidden cards), clamp to top or hide
      if (dist > actualMax) {
         relativePos = 0; 
         opacity = 0;
      } else {
         opacity = 1.0;
      }
      
      // Y calculation
      // cardsStartTop is the TOP of the bubble area bottom.
      
      top = cardsStartTop + (relativePos * headerOffset);
      
      height = collapsedHeight;
    }

    return AnimatedPositioned(
      key: cardKey,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      top: top,
      left: 24,
      right: 24,
      height: height,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: opacity,
        child: GestureDetector(
          onTap: () => onCardTap(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Solid background
                  Container(color: item.color),
                  // Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         // Header
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                             Icon(
                               item.isMaster ? Icons.auto_awesome : Icons.spa,
                               color: HomeColorsExt.midnight,
                               size: 24,
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     item.title,
                                     style: const TextStyle(
                                       fontSize: 18,
                                       fontWeight: FontWeight.bold,
                                       color: HomeColorsExt.midnight,
                                       height: 1.1,
                                     ),
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                     item.subtitle,
                                     style: TextStyle(
                                       fontSize: 13,
                                       color: HomeColorsExt.midnight.withOpacity(0.6),
                                       fontWeight: FontWeight.w500,
                                     ),
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ],
                               ),
                             ),
                             if (dist == 0 && !isExpanded)
                               const Icon(Icons.check_circle, color: Colors.black54, size: 24),
                             if (isExpanded && dist == 0)
                               GestureDetector(
                                 onTap: onCollapse,
                                 child: const Icon(Icons.close, color: Colors.black54, size: 24),
                               ),
                           ],
                         ),
                         
                         const Spacer(),
                         
                         // Collapsed Footer
                         if (!isExpanded && dist == 0) ...[
                           const Divider(height: 24, color: Colors.black12),
                           Row(
                             children: [
                               Text(
                                 'Tap to view',
                                 style: TextStyle(
                                   color: HomeColorsExt.midnight.withOpacity(0.6),
                                   fontWeight: FontWeight.w600,
                                   fontSize: 14,
                                 ),
                               ),
                               const Spacer(),
                               Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withOpacity(0.5),
                                   shape: BoxShape.circle,
                                 ),
                                 child: const Icon(Icons.keyboard_arrow_up, size: 16),
                               ),
                             ],
                           ),
                         ],
                         
                         // Expanded Content
                         if (isExpanded) ...[
                           const SizedBox(height: 20),
                           const Divider(color: Colors.black12),
                           const SizedBox(height: 20),
                           Expanded(
                             child: SingleChildScrollView(
                               physics: const BouncingScrollPhysics(),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   if (hasReactions && !item.isMaster) ...[
                                     _ReactionRadarCard(
                                       counts: item.reactionCounts!,
                                       accent: item.color,
                                     ),
                                     const SizedBox(height: 16),
                                   ],
                                   Text(
                                     item.description,
                                     style: TextStyle(
                                       fontSize: 16,
                                       height: 1.6,
                                       color: HomeColorsExt.midnight.withOpacity(0.8),
                                     ),
                                   ),
                                 ],
                               ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeColorsExt {
  static const midnight = Color(0xFF2B2B3C);
}

class _ReactionRadarCard extends StatelessWidget {
  final Map<String, int> counts;
  final Color accent;

  const _ReactionRadarCard({
    required this.counts,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    final topReactions = reactionTaxonomy
        .where((reaction) => (counts[reaction.key] ?? 0) > 0)
        .map((reaction) => MapEntry(reaction, counts[reaction.key]!))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topThree = topReactions.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.22),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withOpacity(0.85),
                      accent.withOpacity(0.45),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.bubble_chart, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reactions radar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: HomeColorsExt.midnight,
                      ),
                    ),
                    Text(
                      'Collective feelings from recent sessions',
                      style: TextStyle(
                        fontSize: 13,
                        color: HomeColorsExt.midnight.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withOpacity(0.35)),
                ),
                child: Text(
                  '$total reacts',
                  style: TextStyle(
                    color: HomeColorsExt.midnight.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            width: double.infinity,
            child: CustomPaint(
              painter: _ReactionRadarPainter(
                counts: counts,
                accent: accent,
              ),
            ),
          ),
          if (topThree.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topThree
                  .map(
                    (entry) => Chip(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: entry.key.color.withOpacity(0.4)),
                      avatar: Icon(Icons.circle, size: 10, color: entry.key.color),
                      label: Text(
                        '${entry.key.label} • ${entry.value}',
                        style: TextStyle(
                          color: HomeColorsExt.midnight.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReactionRadarPainter extends CustomPainter {
  final Map<String, int> counts;
  final Color accent;

  _ReactionRadarPainter({
    required this.counts,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2.1;

    int maxCount =
        counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);
    if (maxCount <= 0) maxCount = 1;

    final points = <_RadarPoint>[];
    for (int i = 0; i < reactionTaxonomy.length; i++) {
      final reaction = reactionTaxonomy[i];
      final value = counts[reaction.key]?.toDouble() ?? 0;
      final angle = (2 * math.pi / reactionTaxonomy.length) * i - math.pi / 2;
      final normalized = (value / maxCount).clamp(0.0, 1.0);
      final offset = Offset(
        center.dx + math.cos(angle) * radius * normalized,
        center.dy + math.sin(angle) * radius * normalized,
      );
      points.add(_RadarPoint(reaction: reaction, value: value, offset: offset, angle: angle));
    }

    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withOpacity(0.26),
          Colors.white.withOpacity(0.05),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));
    canvas.drawCircle(center, radius * 1.18, bgPaint);

    final gridPaint = Paint()
      ..color = accent.withOpacity(0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int level = 1; level <= 4; level++) {
      final t = level / 4;
      final gridPath = Path();
      for (int i = 0; i < reactionTaxonomy.length; i++) {
        final angle = (2 * math.pi / reactionTaxonomy.length) * i - math.pi / 2;
        final position = Offset(
          center.dx + math.cos(angle) * radius * t,
          center.dy + math.sin(angle) * radius * t,
        );
        if (i == 0) {
          gridPath.moveTo(position.dx, position.dy);
        } else {
          gridPath.lineTo(position.dx, position.dy);
        }
      }
      gridPath.close();
      canvas.drawPath(gridPath, gridPaint);
    }

    final dataPath = Path();
    for (int i = 0; i < points.length; i++) {
      final point = points[i].offset;
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    if (points.isNotEmpty) {
      dataPath.close();
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accent.withOpacity(0.7),
          accent.withOpacity(0.22),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(dataPath, fillPaint);

    final outlinePaint = Paint()
      ..color = accent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(dataPath, outlinePaint);

    for (final point in points) {
      canvas.drawCircle(
        point.offset,
        6,
        Paint()..color = point.reaction.color.withOpacity(0.9),
      );
      canvas.drawCircle(
        point.offset,
        12,
        Paint()
          ..color = point.reaction.color.withOpacity(0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    for (final point in points) {
      final label = '${point.reaction.label} ${counts[point.reaction.key] ?? 0}';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: HomeColorsExt.midnight.withOpacity(0.92),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double labelRadius = radius + 18;
      final labelOffset = Offset(
        center.dx + math.cos(point.angle) * labelRadius - textPainter.width / 2,
        center.dy + math.sin(point.angle) * labelRadius - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _ReactionRadarPainter oldDelegate) {
    return oldDelegate.counts != counts || oldDelegate.accent != accent;
  }
}

class _RadarPoint {
  final ReactionStateData reaction;
  final double value;
  final Offset offset;
  final double angle;

  _RadarPoint({
    required this.reaction,
    required this.value,
    required this.offset,
    required this.angle,
  });
}
