import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/theme/app_theme.dart';
import 'package:framed/features/game/presentation/ingame/ingame_state.dart';
import 'package:framed/features/game/presentation/ingame/widgets/compass_panel.dart';

void main() {
  // #120: the panel lives at the bottom of the scrolling dossier — a pulse
  // that lands while it's below the fold used to spend its whole 30-second
  // window invisible unless the player thought to scroll.
  testWidgets('an arriving pulse scrolls the compass into view', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final compass = IngameCompass(
      bearingDeg: 0,
      distanceM: 100,
      expiresAt: DateTime.now().add(const Duration(seconds: 30)),
      receivedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                const SizedBox(height: 2000),
                CompassPanel(
                  compass: compass,
                  nextPulseAt: null,
                  hasWarning: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(controller.offset, 0);

    // Post-frame callback, then the scroll animation.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final panelRect = tester.getRect(find.byType(CompassPanel));
    final screen = tester.getRect(find.byType(Scaffold));
    expect(controller.offset, greaterThan(0));
    expect(panelRect.bottom, lessThanOrEqualTo(screen.bottom));
    expect(panelRect.top, greaterThanOrEqualTo(screen.top));
  });
}
