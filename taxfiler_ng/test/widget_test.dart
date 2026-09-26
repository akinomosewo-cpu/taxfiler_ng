// Basic smoke test: the dashboard shell should build and render correctly
// once a user is past the auth gate. Full-app auth flow tests live in
// auth_repository_test.dart and login_page_test.dart.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taxfiler_ng/presentation/blocs/tax_bloc.dart';
import 'package:taxfiler_ng/presentation/pages/dashboard_page.dart';

void main() {
  testWidgets('DashboardPage builds and shows the dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => TaxBloc(),
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TaxFiler NG'), findsOneWidget);
    expect(find.textContaining('Filing Deadline'), findsOneWidget);
  });
}
