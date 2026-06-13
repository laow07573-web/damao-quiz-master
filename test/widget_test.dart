import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlashcardApp());
    expect(find.text('刷题助手'), findsOneWidget);
  });
}
