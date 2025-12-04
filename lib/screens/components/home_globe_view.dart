part of 'package:awa_01_spark/screens/home_screen.dart';

class HomeGlobeView extends StatelessWidget {
  final bool isLoading;
  final double? userLatitude;
  final double? userLongitude;

  const HomeGlobeView({
    super.key,
    required this.isLoading,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.white.withOpacity(0.7)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerHeight =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : 360.0;
        final bool showUserLight =
            userLatitude != null && userLongitude != null;
        final globeConfig = GlobeConfig.globe(
          height: containerHeight,
          showUserLight: showUserLight,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          disableInteraction: true,
        );

        return Container(
          color: Colors.black,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GlobeWidget(
                  config: globeConfig,
                  backgroundColor: Colors.black,
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: _globeOverlayGradient),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceholderGlobe extends StatelessWidget {
  const _PlaceholderGlobe();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          painter: _GlobePlaceholderPainter(),
          size: Size.square(size),
        );
      },
    );
  }
}

class _GlobePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final oceanPaint =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF101B45), Color(0xFF0A2F62)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, oceanPaint);

    final atmosphere =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.08
          ..color = const Color(0xFF70C1FF).withOpacity(0.2);
    canvas.drawCircle(center, radius * 1.04, atmosphere);

    final continentPaint =
        Paint()..color = const Color(0xFF8DD694).withOpacity(0.9);

    final path =
        Path()
          ..moveTo(center.dx - radius * 0.3, center.dy - radius * 0.1)
          ..quadraticBezierTo(
            center.dx - radius * 0.15,
            center.dy - radius * 0.4,
            center.dx + radius * 0.05,
            center.dy - radius * 0.2,
          )
          ..quadraticBezierTo(
            center.dx + radius * 0.3,
            center.dy - radius * 0.05,
            center.dx + radius * 0.2,
            center.dy + radius * 0.15,
          )
          ..quadraticBezierTo(
            center.dx,
            center.dy + radius * 0.35,
            center.dx - radius * 0.2,
            center.dy + radius * 0.2,
          )
          ..quadraticBezierTo(
            center.dx - radius * 0.4,
            center.dy,
            center.dx - radius * 0.3,
            center.dy - radius * 0.1,
          )
          ..close();
    canvas.drawPath(path, continentPaint);

    final shimmerPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withOpacity(0.25), Colors.transparent],
          ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(
      center.translate(radius * 0.2, -radius * 0.2),
      radius * 0.6,
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
