import 'package:flutter_test/flutter_test.dart';
import 'package:pandal_hopping_ghatal/main.dart';

void main() {
  testWidgets('App loads and shows Pandal Hopping title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PandalHoppingApp());
    expect(find.text('Pandal Hopping'), findsOneWidget);
  });
}
