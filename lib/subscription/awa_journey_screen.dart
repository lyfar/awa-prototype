import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-page AwaJourney subscription screen
/// Shows all premium benefits and subscription options
class AwaJourneyScreen extends StatefulWidget {
  final bool isCurrentlySubscribed;
  final VoidCallback? onSubscribed;

  const AwaJourneyScreen({
    super.key,
    this.isCurrentlySubscribed = false,
    this.onSubscribed,
  });

  @override
  State<AwaJourneyScreen> createState() => _AwaJourneyScreenState();
}

class _AwaJourneyScreenState extends State<AwaJourneyScreen> {
  int _selectedPlanIndex = 1; // Default to yearly (best value)
  bool _isProcessing = false;

  static const List<_SubscriptionPlan> _plans = [
    _SubscriptionPlan(
      id: 'monthly',
      name: 'Monthly',
      price: '\$9.99',
      period: '/month',
      description: 'Billed monthly',
      savings: null,
    ),
    _SubscriptionPlan(
      id: 'yearly',
      name: 'Yearly',
      price: '\$79.99',
      period: '/year',
      description: 'Billed annually',
      savings: '33% off',
    ),
    _SubscriptionPlan(
      id: 'lifetime',
      name: 'Lifetime',
      price: '\$199.99',
      period: 'one-time',
      description: 'Pay once, own forever',
      savings: 'Best value',
    ),
  ];

  static const List<_BenefitCategory> _benefitCategories = [
    _BenefitCategory(
      title: 'Practices',
      icon: Icons.self_improvement,
      benefits: [
        'Unlimited access to all practice types',
        'Today + Yesterday rotating meditations',
        'Sound meditation library',
        'Special event practices (solstice, etc.)',
        'Download practices for offline use',
      ],
    ),
    _BenefitCategory(
      title: 'Personal Growth',
      icon: Icons.trending_up,
      benefits: [
        'Save unlimited favorite practices',
        'Personal practice journal',
        'Progress tracking & insights',
        'Custom practice reminders',
      ],
    ),
    _BenefitCategory(
      title: 'Community',
      icon: Icons.people_outline,
      benefits: [
        'Join live group sessions',
        'Connect with masters',
        'Exclusive community events',
        'Early access to new features',
      ],
    ),
    _BenefitCategory(
      title: 'Awaway Streaks',
      icon: Icons.local_fire_department,
      benefits: [
        'Extended streak protection',
        'Bonus Lumen rewards',
        'Exclusive streak badges',
        'Priority support',
      ],
    ),
  ];

  void _selectPlan(int index) {
    setState(() {
      _selectedPlanIndex = index;
    });
    print('AwaJourneyScreen: Selected plan ${_plans[index].name}');
  }

  Future<void> _subscribe() async {
    final plan = _plans[_selectedPlanIndex];
    print('AwaJourneyScreen: Starting subscription for ${plan.name}');
    
    setState(() {
      _isProcessing = true;
    });

    // Simulate subscription process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // Show success and callback
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFCB29C), Color(0xFFE88A6E)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.check, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to AwaJourney!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your journey to inner peace begins now.',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close subscription screen
                    widget.onSubscribed?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2B3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Start Exploring',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restorePurchases() {
    print('AwaJourneyScreen: Restoring purchases...');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checking for previous purchases...',
          style: GoogleFonts.urbanist(),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2B2B3C),
                      Color(0xFF1A1A24),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo/Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFCB29C), Color(0xFFE88A6E)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFCB29C).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'AwaJourney',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unlock your full potential',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Benefits section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Everything included',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Benefit categories
                  ..._benefitCategories.map((category) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _BenefitCategoryCard(category: category),
                  )),
                ],
              ),
            ),
          ),

          // Plans section
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF8F8FA),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your plan',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Plan cards
                  ...List.generate(_plans.length, (index) {
                    final plan = _plans[index];
                    final isSelected = index == _selectedPlanIndex;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(
                        plan: plan,
                        isSelected: isSelected,
                        onTap: () => _selectPlan(index),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _subscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2B3C),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              'Subscribe to ${_plans[_selectedPlanIndex].name}',
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Restore purchases
                  Center(
                    child: TextButton(
                      onPressed: _restorePurchases,
                      child: Text(
                        'Restore Purchases',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Terms
                  Text(
                    'By subscribing, you agree to our Terms of Service and Privacy Policy. '
                    'Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: Colors.black38,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}

/// Subscription plan model
class _SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final String description;
  final String? savings;

  const _SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    this.savings,
  });
}

/// Benefit category model
class _BenefitCategory {
  final String title;
  final IconData icon;
  final List<String> benefits;

  const _BenefitCategory({
    required this.title,
    required this.icon,
    required this.benefits,
  });
}

/// Benefit category card widget
class _BenefitCategoryCard extends StatelessWidget {
  final _BenefitCategory category;

  const _BenefitCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCB29C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  size: 22,
                  color: const Color(0xFFE88A6E),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.title,
                style: GoogleFonts.urbanist(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2B2B3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...category.benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    benefit,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Plan selection card widget
class _PlanCard extends StatelessWidget {
  final _SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF7F3) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFCB29C) : Colors.black.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFCB29C).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFFCB29C) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFCB29C) : Colors.black.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Plan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B2B3C),
                        ),
                      ),
                      if (plan.savings != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            plan.savings!,
                            style: GoogleFonts.urbanist(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.price,
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2B2B3C),
                  ),
                ),
                Text(
                  plan.period,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}







