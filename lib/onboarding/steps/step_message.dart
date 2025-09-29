import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class StepMessage extends StatelessWidget {
  final String text;
  final double top;
  final double fontSize;
  final Duration speed;

  const StepMessage({
    super.key,
    required this.text,
    this.top = 40,
    this.fontSize = 24,
    this.speed = const Duration(milliseconds: 70),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Center(
          child: AnimatedTextKit(
            key: ValueKey(text),
            animatedTexts: [
              TypewriterAnimatedText(
                text,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                speed: speed,
              ),
            ],
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
            pause: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }
}
