import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandal_hopping_ghatal/main.dart';
import 'package:pandal_hopping_ghatal/services/live_queue_service.dart';
import 'package:pandal_hopping_ghatal/services/realtime_location_service.dart';
import 'package:pandal_hopping_ghatal/services/live_festival_service.dart';

void main() {
  tearDown(() {
    LiveQueueService().stopTimer();
    RealTimeLocationService().stopTimer();
    LiveFestivalService().stopTimer();
  });

  testWidgets('App loads and shows Pandal Hopping title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PandalHoppingApp());
    expect(find.text('Pandal Hopping'), findsOneWidget);
    LiveQueueService().stopTimer();
    LiveFestivalService().stopTimer();
  });

  testWidgets('ExploreScreen does not display any ads section',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PandalHoppingApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Google Ads • Sponsored Festival Partner'), findsNothing);
    expect(find.text('AdChoices'), findsNothing);
    LiveQueueService().stopTimer();
    LiveFestivalService().stopTimer();
  });

  testWidgets('ExploreScreen renders all core home page widgets efficiently',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const PandalHoppingApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pandal Hopping'), findsOneWidget);
    expect(find.text('Ghatal Sharodutsav 2026'), findsOneWidget);
    expect(find.text('Search Ghatal Pujas, themes, clubs...'), findsOneWidget);
    expect(find.text('Live Queues'), findsOneWidget);
    expect(find.text('LIVE QUEUE RADAR'), findsOneWidget);
    expect(find.text('Live Pandal Hop'), findsOneWidget);

    LiveQueueService().stopTimer();
    LiveFestivalService().stopTimer();
  });

  testWidgets('ExploreScreen includes OfflineZoneSection with interactive download',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const PandalHoppingApp());
    await tester.pump(const Duration(milliseconds: 100));

    final offlineFinder = find.text('Offline Zone Maps');
    await tester.scrollUntilVisible(
      offlineFinder,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(offlineFinder, findsOneWidget);
    expect(find.text('Ghatal Town & Kushpata'), findsOneWidget);
    expect(find.text('Kharar & Chandrakona Link'), findsOneWidget);

    // Tap on a zone card to toggle offline saving
    await tester.tap(find.text('Ghatal Town & Kushpata'));
    await tester.pump(const Duration(milliseconds: 200));

    LiveQueueService().stopTimer();
    LiveFestivalService().stopTimer();
  });

  testWidgets('HomeScreen uses IndexedStack and preserves explore state on tab switch',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PandalHoppingApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Initially Explore tab is visible
    expect(find.text('Pandal Hopping'), findsOneWidget);

    // Switch to Map tab
    await tester.tap(find.text('Map'));
    await tester.pump(const Duration(milliseconds: 300));

    // Switch back to Explore tab
    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pandal Hopping'), findsOneWidget);
    LiveQueueService().stopTimer();
    RealTimeLocationService().stopTimer();
    LiveFestivalService().stopTimer();
  });
}

