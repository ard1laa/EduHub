import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_first_app/main.dart';
import 'package:my_first_app/providers/app_provider.dart';

void main() {
  testWidgets('App smoke test – renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const EduHubApp(),
      ),
    );

    // Allow the splash screen to render.
    await tester.pump();

    // The app should render at least one widget.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
