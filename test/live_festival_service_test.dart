import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandal_hopping_ghatal/services/live_festival_service.dart';
import 'package:pandal_hopping_ghatal/widgets/festival_countdown_badge.dart';

void main() {
  final service = LiveFestivalService();

  setUp(() {
    service.setDisplayMode(CountdownDisplayMode.liveTimer);
    service.setCustomTime(null);
  });

  tearDown(() {
    service.stopTimer();
    service.setCustomTime(null);
  });

  group('LiveFestivalService Unit Tests', () {
    test('Calculates correct countdown when on Maha Shashthi (Oct 16)', () {
      // Set to 2026-10-16 00:00:00 (Maha Shashthi start)
      service.setCustomTime(DateTime(2026, 10, 16, 0, 0, 0));

      // Saptami is 2026-10-18 00:00:00 (exact 2 days / 48 hours away)
      expect(service.currentPhase, FestivalPhase.mahaShashthi);
      expect(service.liveTimerBadgeText, 'MAHA SAPTAMI IN 2D 00H 00M 00S');
      expect(service.calendarDaysBadgeText, 'MAHA SHASHTHI TODAY • SAPTAMI IN 2 DAYS');
    });

    test('Calculates live time ticking for 1 day and 23 hours (Oct 16 00:56 AM)', () {
      // Set to 2026-10-16 00:56:08
      service.setCustomTime(DateTime(2026, 10, 16, 0, 56, 8));

      // 47 hours, 3 minutes, 52 seconds left
      expect(service.currentPhase, FestivalPhase.mahaShashthi);
      expect(service.liveTimerBadgeText, 'MAHA SAPTAMI IN 1D 23H 03M 52S');
    });

    test('Transitions to Saptami countdown under 24 hours on Oct 17', () {
      // Set to 2026-10-17 12:00:00 (12 hours left until Oct 18 00:00:00)
      service.setCustomTime(DateTime(2026, 10, 17, 12, 0, 0));

      expect(service.liveTimerBadgeText, 'MAHA SAPTAMI IN 12H 00M 00S');
      expect(service.calendarDaysBadgeText, 'MAHA SAPTAMI TOMORROW (IN 1 DAY)');
    });

    test('Transitions to Maha Saptami Live on Oct 18', () {
      // Set to 2026-10-18 10:00:00
      service.setCustomTime(DateTime(2026, 10, 18, 10, 0, 0));

      expect(service.currentPhase, FestivalPhase.mahaSaptami);
      expect(service.liveTimerBadgeText.startsWith('MAHA SAPTAMI LIVE'), isTrue);
      expect(service.calendarDaysBadgeText, 'MAHA SAPTAMI TODAY • PUJA LIVE');
    });

    test('Detects Sandhi Puja live window on Maha Ashtami', () {
      // Sandhi Puja is 2026-10-19 from 10:27 AM to 11:15 AM
      service.setCustomTime(DateTime(2026, 10, 19, 10, 30, 0));

      expect(service.currentPhase, FestivalPhase.sandhiPuja);
      expect(service.badgeText.contains('SANDHI PUJA LIVE'), isTrue);
    });

    test('Toggles display modes correctly', () {
      service.setDisplayMode(CountdownDisplayMode.liveTimer);
      expect(service.displayMode, CountdownDisplayMode.liveTimer);

      service.toggleDisplayMode();
      expect(service.displayMode, CountdownDisplayMode.calendarDays);

      service.toggleDisplayMode();
      expect(service.displayMode, CountdownDisplayMode.liveClock);

      service.toggleDisplayMode();
      expect(service.displayMode, CountdownDisplayMode.liveTimer);
    });
  });

  group('FestivalCountdownBadge Widget Tests', () {
    testWidgets('Renders live countdown text and opens schedule sheet on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      service.setCustomTime(DateTime(2026, 10, 16, 0, 56, 8));
      service.setDisplayMode(CountdownDisplayMode.liveTimer);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: FestivalCountdownBadge(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('MAHA SAPTAMI IN 1D 23H 03M 52S'), findsOneWidget);

      // Tap badge to open schedule sheet
      await tester.tap(find.byType(FestivalCountdownBadge));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Ghatal Sharodutsav 2026'), findsOneWidget);
      expect(find.text('Live Puja Schedule & Tithi Countdown'), findsOneWidget);
      expect(find.text('COUNTDOWN TO MAHA SAPTAMI'), findsOneWidget);
      expect(find.text('Maha Shashthi'), findsOneWidget);
      expect(find.text('Maha Saptami'), findsOneWidget);
      expect(find.text('Maha Ashtami & Sandhi Puja'), findsOneWidget);

      // Tap Calendar Days mode chip
      final calendarFinder = find.text('Calendar Days');
      await tester.scrollUntilVisible(
        calendarFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(calendarFinder);
      await tester.pump(const Duration(milliseconds: 350));

      expect(service.displayMode, CountdownDisplayMode.calendarDays);
    });
  });
}
