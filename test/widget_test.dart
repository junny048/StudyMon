import 'package:flutter_test/flutter_test.dart';
import 'package:studymon/main.dart';

void main() {
  testWidgets('home screen renders StudyMon and Start Study button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudyMonApp());

    expect(find.text('StudyMon'), findsOneWidget);
    expect(find.text('Start Study'), findsOneWidget);
    expect(find.textContaining('Today Study Time'), findsOneWidget);
  });
}
