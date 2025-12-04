import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/backend_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print('LoadingScreen: Initializing logo animation');
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadAppData();
  }

  Future<void> _loadAppData() async {
    print('LoadingScreen: Loading app data');
    try {
      await BackendService.loadAppData();
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        print('LoadingScreen: Navigating to welcome screen');
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    } catch (e) {
      print('LoadingScreen: Error loading data - $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Awaterra Logo - Three overlapping shapes
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _AwaterraLogoPainter(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Awaterra',
                    style: GoogleFonts.urbanist(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AwaterraLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.32;
    
    // Colors from the logo
    const peachColor = Color(0xFFFCB29C);
    const coralColor = Color(0xFFE8927C);
    const pinkColor = Color(0xFFDDA0B0);
    
    // Draw three overlapping ellipses
    final paint1 = Paint()
      ..color = peachColor
      ..style = PaintingStyle.fill;
    
    final paint2 = Paint()
      ..color = coralColor
      ..style = PaintingStyle.fill;
    
    final paint3 = Paint()
      ..color = pinkColor
      ..style = PaintingStyle.fill;

    // Top-left ellipse (peach)
    canvas.save();
    canvas.translate(center.dx - radius * 0.3, center.dy - radius * 0.2);
    canvas.rotate(-0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 1.4, height: radius * 0.9),
      paint1,
    );
    canvas.restore();

    // Bottom ellipse (coral/orange)
    canvas.save();
    canvas.translate(center.dx, center.dy + radius * 0.3);
    canvas.rotate(0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 1.5, height: radius * 0.85),
      paint2,
    );
    canvas.restore();

    // Top-right ellipse (pink)
    canvas.save();
    canvas.translate(center.dx + radius * 0.3, center.dy - radius * 0.3);
    canvas.rotate(0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 1.2, height: radius * 0.8),
      paint3,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
