import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'soul_states.dart';

class SoulRenderer extends StatefulWidget {
  final SoulConfig config;

  const SoulRenderer({super.key, required this.config});

  @override
  State<SoulRenderer> createState() => _SoulRendererState();
}

class _SoulRendererState extends State<SoulRenderer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFF4F8B),
      const Color(0xFFFFC371),
      const Color(0xFF8EC5FC),
    ];

    final state = widget.config.state;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scale = state == SoulState.light
            ? 0.8 + math.sin(t * math.pi) * 0.05
            : 1.0 + math.sin(t * math.pi * 2) * 0.08;
        return Container(
          color: widget.config.backgroundColor,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: colors,
              center: Alignment(0.0, -0.2),
              radius: 1.2,
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x55FF5F8F),
                      blurRadius: 80,
                      spreadRadius: 12,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6FB1), Color(0xFFFFC96F)],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
