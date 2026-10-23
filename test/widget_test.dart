import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('Splash screen shows BharatDex', (tester) async {
    await tester.pumpWidget(const BharatDexApp());
    await tester.pump();
    expect(find.text('BharatDex'), findsOneWidget);
  });
}