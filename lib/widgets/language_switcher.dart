import 'package:flutter/material.dart';
import '../services/language_service.dart';

/// Language switcher drawer widget
/// Displays available languages and allows user selection
class LanguageSwitcher extends StatefulWidget {
  final VoidCallback? onLanguageChanged;
  final bool isVisible;
  
  const LanguageSwitcher({
    super.key,
    this.onLanguageChanged,
    this.isVisible = false,
  });

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print('LanguageSwitcher: Initializing language switcher widget');
    
    // Setup animations for smooth drawer appearance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void didUpdateWidget(LanguageSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate drawer in/out based on visibility
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        print('LanguageSwitcher: Showing language drawer');
        _animationController.forward();
      } else {
        print('LanguageSwitcher: Hiding language drawer');
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(String languageCode) async {
    print('LanguageSwitcher: User selected language: $languageCode');
    
    // Update language service
    await LanguageService.setLanguage(languageCode);
    
    // Notify parent widget
    widget.onLanguageChanged?.call();
    
    print('LanguageSwitcher: Language change completed');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          left: 20 + (MediaQuery.of(context).size.width * 0.5 * _slideAnimation.value),
          top: 40,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.language,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LanguageService.getText('language'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Language options
                  ...LanguageService.supportedLanguages.entries.map((entry) {
                    final isSelected = entry.key == LanguageService.currentLanguage;
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectLanguage(entry.key),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(
                                entry.value,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
                                  fontSize: 15,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.w400,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
