import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/language_service.dart';
import 'language_picker_modal.dart';

class WelcomeStep extends StatefulWidget {
  final VoidCallback onContinue;

  const WelcomeStep({super.key, required this.onContinue});

  @override
  State<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends State<WelcomeStep> {
  
  void _openLanguagePicker() {
    print('WelcomeStep: Opening language picker');
    LanguagePickerModal.show(
      context,
      onLanguageChanged: () {
        print('WelcomeStep: Language changed, rebuilding');
        setState(() {});
      },
    );
  }

  String get _currentLanguageName {
    return LanguageService.supportedLanguages[LanguageService.currentLanguage] ?? 'English';
  }

  @override
  Widget build(BuildContext context) {
    print('WelcomeStep: Building welcome screen - language: ${LanguageService.currentLanguage}');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top spacing - pushes content to bottom half
            const Spacer(flex: 5),
            
            // Title
            Text(
              'Welcome',
              style: GoogleFonts.playfairDisplay(
                fontSize: 40,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            
            // Body text with tappable language
            Text.rich(
              TextSpan(
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'Breathe out.\n'),
                  const TextSpan(text: "We're glad you're here.\n"),
                  const TextSpan(text: "You're in the right place.\n"),
                  const TextSpan(text: 'A quiet pause from constant noise.\n'),
                  const TextSpan(text: "We'll speak with you in "),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: _openLanguagePicker,
                      child: Text(
                        _currentLanguageName,
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          color: const Color(0xFFFCB29C),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFFCB29C),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print('WelcomeStep: Continue pressed');
                  widget.onContinue();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  foregroundColor: const Color(0xFFD4A5A5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
