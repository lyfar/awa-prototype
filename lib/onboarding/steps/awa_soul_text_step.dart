import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AwaSoulTextStep extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onContinue;
  final bool isStartJourney;

  const AwaSoulTextStep({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onContinue,
    this.isStartJourney = false,
  });

  @override
  Widget build(BuildContext context) {
    print('AwaSoulTextStep: Building step - $title');
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  description,
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  child: isStartJourney 
                    ? _buildStartJourneyButton()
                    : _buildContinueButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        print('AwaSoulTextStep: $buttonText pressed');
        onContinue();
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
        buttonText,
        style: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStartJourneyButton() {
    return GestureDetector(
      onTap: () {
        print('AwaSoulTextStep: Start Journey pressed');
        onContinue();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE8D5D0),
              Color(0xFFD4A5B0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
