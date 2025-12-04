part of 'package:awa_01_spark/screens/home_screen.dart';

class HomeStartButton extends StatelessWidget {
  final bool isEnabled;
  final bool hasPracticedToday;
  final VoidCallback onPressed;

  const HomeStartButton({
    super.key,
    required this.isEnabled,
    required this.hasPracticedToday,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.45,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _activeButtonGradient,
                boxShadow: [
                  BoxShadow(
                    color: _emberPeach.withOpacity(0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: _spaceBlack,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
