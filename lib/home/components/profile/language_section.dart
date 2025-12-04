import 'package:flutter/material.dart';
import '../../../services/language_service.dart';
import '../../theme/home_colors.dart';

const Color _ink = Colors.white;

class LanguageSection extends StatefulWidget {
  const LanguageSection({super.key});

  @override
  State<LanguageSection> createState() => _LanguageSectionState();
}

class _LanguageSectionState extends State<LanguageSection> {
  @override
  Widget build(BuildContext context) {
    final code = LanguageService.currentLanguage;
    final current = LanguageService.supportedLanguages[code] ?? 'English';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _openLanguageDrawer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        current,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openLanguageDrawer() async {
    final currentCode = LanguageService.currentLanguage;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        String selectedCode = currentCode;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: HomeColors.space,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Language',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Selected language',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...LanguageService.supportedLanguages.entries.map(
                          (entry) {
                            final isSelected = selectedCode == entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    setModalState(() => selectedCode = entry.key);
                                    await LanguageService.setLanguage(entry.key);
                                    if (mounted) {
                                      setState(() {});
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          entry.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Spacer(),
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color: isSelected
                                              ? HomeColors.peach
                                              : Colors.white.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
