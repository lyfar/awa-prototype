import 'package:flutter/material.dart';
import '../../services/language_service.dart';

class DataHandshakeCard extends StatelessWidget {
  final TextEditingController nameController;
  final FocusNode? nameFocusNode;
  final ValueChanged<String>? onNameChanged;
  final String? nameError;
  final bool hasAcceptedPolicy;
  final bool policyError;
  final ValueChanged<bool>? onPolicyChanged;
  final bool isRequesting;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const DataHandshakeCard({
    super.key,
    required this.nameController,
    this.nameFocusNode,
    this.onNameChanged,
    this.nameError,
    required this.hasAcceptedPolicy,
    required this.policyError,
    this.onPolicyChanged,
    required this.isRequesting,
    required this.onAllow,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = Colors.white.withOpacity(0.08);
    final borderColor = Colors.white.withOpacity(0.18);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.32),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.getText('welcome_name_label'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            focusNode: nameFocusNode,
            onChanged: onNameChanged,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: LanguageService.getText('welcome_name_placeholder'),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 16,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      (nameError != null)
                          ? Colors.redAccent.withOpacity(0.6)
                          : Colors.white.withOpacity(0.18),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      (nameError != null)
                          ? Colors.redAccent.withOpacity(0.8)
                          : Colors.white.withOpacity(0.32),
                  width: 1.4,
                ),
              ),
            ),
          ),
          if (nameError != null) ...[
            const SizedBox(height: 8),
            Text(
              nameError!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          _PolicyToggle(
            isChecked: hasAcceptedPolicy,
            hasError: policyError,
            onChanged: (value) => onPolicyChanged?.call(value),
          ),
          if (policyError) ...[
            const SizedBox(height: 6),
            Text(
              LanguageService.getText('welcome_policy_error'),
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            LanguageService.getText('location_description'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isRequesting ? null : onAllow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.22),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.28),
                  width: 1,
                ),
              ),
              child:
                  isRequesting
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.9),
                          ),
                        ),
                      )
                      : Text(
                        LanguageService.getText('allow_location'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: isRequesting ? null : onSkip,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.75),
              ),
              child: Text(
                LanguageService.getText('skip_location'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyToggle extends StatelessWidget {
  final bool isChecked;
  final bool hasError;
  final ValueChanged<bool>? onChanged;

  const _PolicyToggle({
    required this.isChecked,
    required this.hasError,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!isChecked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color:
                    hasError ? Colors.redAccent : Colors.white.withOpacity(0.4),
                width: 1.2,
              ),
              color:
                  isChecked
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
            ),
            child:
                isChecked
                    ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              LanguageService.getText('welcome_policy_ack'),
              style: TextStyle(
                color:
                    hasError
                        ? Colors.redAccent
                        : Colors.white.withOpacity(0.78),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
