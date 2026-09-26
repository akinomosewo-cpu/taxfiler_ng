// Basic smoke test: the app should build and show the dashboard shell.

import 'package:flutter_test/flutter_test.dart';

import 'package:taxfiler_ng/main.dart';

void main() {
  testWidgets('TaxFilerApp builds and shows the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const TaxFilerApp());
    await tester.pumpAndSettle();

    expect(find.text('TaxFiler NG'), findsOneWidget);
    expect(find.textContaining('Filing Deadline'), findsOneWidget);
  });
}
