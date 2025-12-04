import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/loading_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MindfulnessApp());
}

class MindfulnessApp extends StatelessWidget {
  const MindfulnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF090913);
    const Color surface = Color(0xFF1B1B26);
    const Color accent = Color(0xFFFCB29C);

    return MaterialApp(
      title: 'Mindfulness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          background: background,
          surface: surface,
        ),
        textTheme: GoogleFonts.urbanistTextTheme()
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
