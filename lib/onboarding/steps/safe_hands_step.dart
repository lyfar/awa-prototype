import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafeHandsStep extends StatelessWidget {
  final VoidCallback onContinue;

  const SafeHandsStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Logo
              Center(
                 child: Icon(Icons.spa, color: const Color(0xFFFCB29C), size: 60),
              ),
              const SizedBox(height: 40),
              Text(
                "You're in safe\nhands",
                style: GoogleFonts.urbanist(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              _buildBulletPoint("No ads"),
              const SizedBox(height: 16),
              _buildBulletPoint("No ad tracking"),
              const SizedBox(height: 16),
              _buildBulletPoint("No data sales"),
              
              const Spacer(),
              
              Text(
                "Location and activity – only with your consent. Only essential technical data.\nMore details in our Privacy Policy.",
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B1B26),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFFCB29C), // Accent color
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: GoogleFonts.urbanist(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

