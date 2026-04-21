import 'package:flutter_test/flutter_test.dart';

import 'package:drawing_app/main.dart';

void main() {
  testWidgets('Drawing app renders main tools', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Shapes'), findsOneWidget);
    expect(find.text('Style'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });
}
