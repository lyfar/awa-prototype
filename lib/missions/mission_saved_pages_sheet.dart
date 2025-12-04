import 'package:flutter/material.dart';

class MissionSavedPagesSheet extends StatelessWidget {
  final List<String> pageAssets;
  final String missionTitle;

  const MissionSavedPagesSheet({
    super.key,
    required this.pageAssets,
    required this.missionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Favourite pages from $missionTitle',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PageView.builder(
              itemCount: pageAssets.length,
              itemBuilder: (_, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.menu_book,
                            color: Colors.white.withOpacity(0.4),
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Page ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Preview of digitized manuscript page. Tap Share to export.',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
