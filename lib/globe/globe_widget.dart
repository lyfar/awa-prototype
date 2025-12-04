import 'package:flutter/material.dart';
import 'globe_states.dart';
import 'globe_widget_stub.dart' if (dart.library.html) 'globe_widget_web.dart';

/// Universal globe widget that handles all 3 states:
/// - Light: Single bright dot (welcome step 1)
/// - AwaSoul: Particle cloud (welcome step 2, practice mode)
/// - Globe: Earth + particles (welcome step 3, home screen)
class GlobeWidget extends StatefulWidget {
  final GlobeConfig config;
  final Color backgroundColor;

  const GlobeWidget({
    super.key,
    required this.config,
    this.backgroundColor = Colors.black,
  });

  @override
  State<GlobeWidget> createState() => _GlobeWidgetState();

  /// Static method to trigger state transitions (for welcome screen flow)
  static void transitionToAwaSoul() {
    GlobeRenderer.transitionToAwaSoul();
  }

  /// Static method to trigger state transitions (for welcome screen flow)
  static void transitionToGlobe() {
    GlobeRenderer.transitionToGlobe();
  }

  /// Static method to trigger transition back to light state
  static void transitionToLight() {
    GlobeRenderer.transitionToLight();
  }

  /// Static method to trigger transition from globe to awaSoul
  static void transitionGlobeToAwaSoul() {
    GlobeRenderer.transitionGlobeToAwaSoul();
  }
}

class _GlobeWidgetState extends State<GlobeWidget> {
  @override
  Widget build(BuildContext context) {
    print(
      'GlobeWidget: Building with state=${widget.config.state.name}, showUserLight=${widget.config.showUserLight}, userLat=${widget.config.userLatitude}, userLng=${widget.config.userLongitude}',
    );
    final height = widget.config.height;
    final globe = DecoratedBox(
      decoration: BoxDecoration(color: widget.backgroundColor),
      child: GlobeRenderer(
        config: widget.config,
        backgroundColor: widget.backgroundColor,
      ),
    );

    if (height.isFinite) {
      return SizedBox(height: height, width: double.infinity, child: globe);
    }

    return SizedBox.expand(child: globe);
  }

  @override
  void didUpdateWidget(covariant GlobeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.state != widget.config.state ||
        oldWidget.config.showUserLight != widget.config.showUserLight ||
        oldWidget.config.userLatitude != widget.config.userLatitude ||
        oldWidget.config.userLongitude != widget.config.userLongitude) {
      // Globe state or user data changed, update renderer
      print('GlobeWidget: Config changed - updating renderer');
    }
  }
}
