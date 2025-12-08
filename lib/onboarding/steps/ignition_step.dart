import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IgnitionStep extends StatefulWidget {
  final VoidCallback onIgnite;

  const IgnitionStep({super.key, required this.onIgnite});

  @override
  State<IgnitionStep> createState() => _IgnitionStepState();
}

class _IgnitionStepState extends State<IgnitionStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Hold duration
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onIgnite();
      }
    });
  }

  void _startHolding() {
    setState(() => _isHolding = true);
    _controller.forward();
  }

  void _stopHolding() {
    if (_controller.status != AnimationStatus.completed) {
      setState(() => _isHolding = false);
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return GestureDetector(
                  onLongPressStart: (_) => _startHolding(),
                  onLongPressEnd: (_) => _stopHolding(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      Opacity(
                        opacity: _glowAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD54F).withOpacity(0.6),
                                blurRadius: 50 * _scaleAnimation.value,
                                spreadRadius: 20 * _scaleAnimation.value,
                              ),
                              BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.4),
                                blurRadius: 80 * _scaleAnimation.value,
                                spreadRadius: 40 * _scaleAnimation.value,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Button Core
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            Opacity(
              opacity: _isHolding ? 0.5 : 1.0,
              child: Text(
                "Hold to Ignite...",
                style: GoogleFonts.urbanist(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


