part of 'package:awa_01_spark/screens/home_screen.dart';

class HomeSectionPlaceholder extends StatelessWidget {
  final HomeSection section;

  const HomeSectionPlaceholder({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('section-${section.name}'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 160, child: _PlaceholderGlobe()),
              const SizedBox(height: 16),
              Text(
                '${section.label} coming soon',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                section.description,
                style: TextStyle(color: Colors.black54, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
