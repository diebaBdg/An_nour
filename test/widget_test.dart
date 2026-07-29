import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:an_nour/app.dart';

void main() {
  testWidgets('An-Nour app loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AnNourApp(),
      ),
    );

    expect(find.text('Assalamu Alaikum'), findsOneWidget);
  });
}
