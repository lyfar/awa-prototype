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
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            Text(
              description,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Button
            SizedBox(
              width: double.infinity,
              child: isStartJourney 
                ? _buildStartJourneyButton()
                : _buildContinueButton(),
            ),
            
            const SizedBox(height: 40),
          ],
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
