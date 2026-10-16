import 'package:flutter_test/flutter_test.dart';
import 'package:wordle_app/main.dart';

void main() {
  testWidgets('Wordle app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WordleApp());
    expect(find.text('WORDLE'), findsNothing); // splash screen shown first

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
