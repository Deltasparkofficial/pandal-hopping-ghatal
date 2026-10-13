import 'package:flutter_test/flutter_test.dart';
import 'package:pandal_hopping_ghatal/main.dart';
import 'package:pandal_hopping_ghatal/services/live_queue_service.dart';

void main() {
  tearDown(() {
    LiveQueueService().stopTimer();
  });

  testWidgets('App loads and shows Pandal Hopping title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PandalHoppingApp());
    expect(find.text('Pandal Hopping'), findsOneWidget);
    LiveQueueService().stopTimer();
  });

  testWidgets('ExploreScreen does not display any ads section',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PandalHoppingApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Google Ads • Sponsored Festival Partner'), findsNothing);
    expect(find.text('AdChoices'), findsNothing);
    LiveQueueService().stopTimer();
  });
}

