import 'package:flutter/material.dart';
import '../../models/meditation_models.dart';
import 'profile/profile_header.dart';
import 'profile/user_info_section.dart';
import 'profile/language_section.dart';
import 'profile/debug_section.dart';

/// Sliding profile panel that opens from the right
/// Contains user info and debug controls
class ProfilePanel extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;
  final bool hasPracticedToday;
  final double? userLatitude;
  final double? userLongitude;
  final PracticeFlowState practiceState;
  final Function(bool) onPracticeStateChanged;

  const ProfilePanel({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.hasPracticedToday,
    this.userLatitude,
    this.userLongitude,
    required this.practiceState,
    required this.onPracticeStateChanged,
  });

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 2 / 3; // 2/3 of screen width

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: 0,
      right: widget.isVisible ? 0 : -panelWidth,
      width: panelWidth,
      height: MediaQuery.of(context).size.height,
      child: Material(
        elevation: 20, // High elevation to ensure it's above other widgets
        color: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.98), // Slightly more opaque
              border: Border(
                left: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 2, // Thicker border for better visibility
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SafeArea(
          child: Column(
            children: [
              // Panel header
              ProfileHeader(onClose: widget.onClose),

              // Panel content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info section
                      UserInfoSection(
                        hasPracticedToday: widget.hasPracticedToday,
                        userLatitude: widget.userLatitude,
                        userLongitude: widget.userLongitude,
                        practiceState: widget.practiceState,
                      ),

                      const SizedBox(height: 30),

                      // Language section
                      const LanguageSection(),

                      const SizedBox(height: 30),

                      // Debug section
                      DebugSection(
                        onPracticeStateChanged: widget.onPracticeStateChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
            ),
        ),
      ),
    );
  }
}
