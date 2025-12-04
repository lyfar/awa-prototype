import 'package:awa_01_spark/globe/globe_widget.dart';
import 'package:awa_01_spark/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home screen renders globe view by default', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Allow async initialization to finish without waiting forever on animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(GlobeWidget), findsOneWidget);
  });
}
