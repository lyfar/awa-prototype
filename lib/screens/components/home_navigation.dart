part of 'package:awa_01_spark/screens/home_screen.dart';

class HomeNavigationOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final Widget child;

  const HomeNavigationOverlay({super.key, required this.onClose, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: _spaceBlack.withOpacity(0.85)),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
