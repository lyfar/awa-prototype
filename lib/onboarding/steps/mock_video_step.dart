import 'package:flutter/material.dart';

class MockVideoStep extends StatelessWidget {
  final VoidCallback onContinue;

  const MockVideoStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onContinue,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Placeholder for video thumbnail
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.blueGrey.shade900.withOpacity(0.3),
                      Colors.black,
                    ],
                  ),
                ),
              ),
              // Video Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              Positioned(
                bottom: 60,
                child: Text(
                  "Tap to skip video",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


