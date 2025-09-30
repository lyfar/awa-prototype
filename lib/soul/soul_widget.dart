import 'package:flutter/material.dart';
import 'soul_states.dart';
import 'soul_widget_stub.dart'
    if (dart.library.html) 'soul_widget_web.dart';

class SoulWidget extends StatefulWidget {
  final SoulConfig config;

  const SoulWidget({super.key, required this.config});

  @override
  State<SoulWidget> createState() => _SoulWidgetState();
}

class _SoulWidgetState extends State<SoulWidget> {
  @override
  Widget build(BuildContext context) {
    final height = widget.config.height;
    final soul = DecoratedBox(
      decoration: BoxDecoration(color: widget.config.backgroundColor),
      child: SoulRenderer(config: widget.config),
    );

    if (height.isFinite) {
      return SizedBox(height: height, width: double.infinity, child: soul);
    }

    return SizedBox.expand(child: soul);
  }
}
