import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/language_service.dart';

/// Language picker modal that matches the onboarding design
class LanguagePickerModal extends StatelessWidget {
  final VoidCallback? onLanguageChanged;

  const LanguagePickerModal({super.key, this.onLanguageChanged});

  static Future<void> show(BuildContext context, {VoidCallback? onLanguageChanged}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LanguagePickerModal(onLanguageChanged: onLanguageChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('LanguagePickerModal: Building language picker');
    
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selected Language',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Language options
          _buildLanguageOption(
            context,
            code: 'en',
            nativeName: 'English',
            englishName: null,
          ),
          
          Divider(
            height: 1,
            indent: 24,
            endIndent: 24,
            color: Colors.black.withOpacity(0.05),
          ),
          
          _buildLanguageOption(
            context,
            code: 'ru',
            nativeName: 'Русский',
            englishName: 'Russian',
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String code,
    required String nativeName,
    String? englishName,
  }) {
    final isSelected = LanguageService.currentLanguage == code;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          print('LanguagePickerModal: Selected language - $code');
          await LanguageService.setLanguage(code);
          onLanguageChanged?.call();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      nativeName,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    if (englishName != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        englishName,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Checkmark
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                    ? const Color(0xFFFCB29C).withOpacity(0.2)
                    : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                      ? const Color(0xFFFCB29C)
                      : Colors.black12,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Color(0xFFFCB29C),
                    )
                  : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


