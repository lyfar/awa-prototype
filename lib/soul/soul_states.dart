import 'package:flutter/material.dart';

enum SoulState {
  /// Single particle breathing in place
  light,

  /// Human-like sculpture silhouette
  human,

  /// Abstract mask (Suzanne monkey)
  mask,

  /// Particles forming a globe silhouette
  globe,
}

class SoulConfig {
  final SoulState state;
  final double height;
  final bool disableInteraction;
  final bool autoCycle;
  final bool immediate;
  final Color backgroundColor;

  const SoulConfig({
    required this.state,
    this.height = 400,
    this.disableInteraction = false,
    this.autoCycle = true,
    this.immediate = false,
    this.backgroundColor = Colors.white,
  });

  factory SoulConfig.light({
    double height = 400,
    bool disableInteraction = false,
  }) {
    return SoulConfig(
      state: SoulState.light,
      height: height,
      disableInteraction: disableInteraction,
      autoCycle: false,
      immediate: true,
      backgroundColor: Colors.white,
    );
  }

  factory SoulConfig.human({
    double height = 400,
    bool disableInteraction = false,
    bool autoCycle = false,
  }) {
    return SoulConfig(
      state: SoulState.human,
      height: height,
      disableInteraction: disableInteraction,
      autoCycle: autoCycle,
      backgroundColor: Colors.white,
    );
  }

  factory SoulConfig.mask({
    double height = 400,
    bool disableInteraction = false,
    bool autoCycle = false,
  }) {
    return SoulConfig(
      state: SoulState.mask,
      height: height,
      disableInteraction: disableInteraction,
      autoCycle: autoCycle,
      backgroundColor: Colors.white,
    );
  }

  factory SoulConfig.globe({
    double height = 400,
    bool disableInteraction = false,
    bool autoCycle = false,
    bool immediate = false,
    Color backgroundColor = Colors.transparent,
  }) {
    return SoulConfig(
      state: SoulState.globe,
      height: height,
      disableInteraction: disableInteraction,
      autoCycle: autoCycle,
      immediate: immediate,
      backgroundColor: backgroundColor,
    );
  }

  SoulConfig copyWith({
    SoulState? state,
    double? height,
    bool? disableInteraction,
    bool? autoCycle,
    bool? immediate,
    Color? backgroundColor,
  }) {
    return SoulConfig(
      state: state ?? this.state,
      height: height ?? this.height,
      disableInteraction: disableInteraction ?? this.disableInteraction,
      autoCycle: autoCycle ?? this.autoCycle,
      immediate: immediate ?? this.immediate,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}
