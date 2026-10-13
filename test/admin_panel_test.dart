import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandal_hopping_ghatal/screens/admin_panel_screen.dart';
import 'package:pandal_hopping_ghatal/services/live_queue_service.dart';

void main() {
  setUp(() {
    AdminPanelScreen.sessionUnlocked = false;
    AdminPanelScreen.activePasscode = 'admin123';
  });

  tearDown(() {
    LiveQueueService().stopTimer();
  });

  testWidgets('AdminPanelScreen requires password and does NOT display default password section',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminPanelScreen(),
      ),
    );

    // Should show Admin Security Gate
    expect(find.text('Admin Security Gate'), findsOneWidget);
    expect(find.text('Unlock Admin Console'), findsOneWidget);
    expect(find.text('ADMINISTRATOR PASSCODE'), findsOneWidget);

    // Default password and quick unlock must NOT be displayed
    expect(find.text('Default Passcode:'), findsNothing);
    expect(find.text('Quick Unlock'), findsNothing);
    expect(find.text('admin123'), findsNothing);

    // Full console controls should not be visible
    expect(find.text('Admin Command Center'), findsNothing);
    expect(find.text('Live Queue Controller'), findsNothing);

    LiveQueueService().stopTimer();
  });

  testWidgets('AdminPanelScreen shows error on invalid password without leaking default password',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminPanelScreen(),
      ),
    );

    // Enter wrong password
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    await tester.enterText(textField, 'wrongpass');
    await tester.tap(find.text('Unlock Admin Console'));
    await tester.pump();

    // Verify error message is shown without revealing the default password
    expect(find.text('Incorrect password. Please try again.'), findsOneWidget);
    expect(find.text('Admin Command Center'), findsNothing);

    LiveQueueService().stopTimer();
  });

  testWidgets('AdminPanelScreen unlocks on correct password and can be locked',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminPanelScreen(),
      ),
    );

    // Enter correct password
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'admin123');
    await tester.tap(find.text('Unlock Admin Console'));
    await tester.pumpAndSettle();

    // Verify admin console is now unlocked
    expect(find.text('Admin Command Center'), findsOneWidget);
    expect(find.text('Admin Session Active'), findsOneWidget);
    expect(find.text('Live Queue Controller'), findsOneWidget);

    // Test locking the console
    final lockButton = find.byTooltip('Lock Admin Console');
    expect(lockButton, findsOneWidget);
    await tester.tap(lockButton);
    await tester.pumpAndSettle();

    // Should be locked again
    expect(find.text('Admin Security Gate'), findsOneWidget);
    expect(find.text('Admin Command Center'), findsNothing);

    LiveQueueService().stopTimer();
  });
}
