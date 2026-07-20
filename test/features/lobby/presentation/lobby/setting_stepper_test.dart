import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/theme/app_theme.dart';
import 'package:framed/features/lobby/presentation/lobby/setting_stepper.dart';

/// Drives a [SettingStepper] as a controlled component: the harness owns the
/// value the way LobbySettingsPage's bloc does, so onChanged actually moves
/// the number and rebuilds, which is what surfaces the focus/desync bugs.
Future<void> _pump(
  WidgetTester tester, {
  required int initial,
  required void Function(int) onChanged,
  required ValueGetter<int> current,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SettingStepper(
            label: 'Dispersal time',
            info: 'How long before targets are assigned.',
            value: current(),
            unit: 'min',
            onChanged: (v) => setState(() => onChanged(v)),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the + button increments the shown value', (tester) async {
    var value = 5;
    await _pump(
      tester,
      initial: value,
      onChanged: (v) => value = v,
      current: () => value,
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(value, 6);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('− stops at the minimum of 1', (tester) async {
    var value = 1;
    await _pump(
      tester,
      initial: value,
      onChanged: (v) => value = v,
      current: () => value,
    );

    // Disabled at the floor: the value can't go to 0.
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pump();
    expect(value, 1);
  });

  // The regression the review caught (#106): tapping into the field and then
  // pressing + froze the display while the underlying value climbed, and
  // blurring committed the stale on-screen number — silently reverting every
  // press. The field must track the +/- presses even while focused.
  testWidgets(
    'pressing + while the field has focus updates the field, and blur keeps it',
    (tester) async {
      var value = 5;
      await _pump(
        tester,
        initial: value,
        onChanged: (v) => value = v,
        current: () => value,
      );

      // Focus the text field, as a host tapping into it does.
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(
        FocusScope.of(tester.element(find.byType(TextField))).hasFocus,
        isTrue,
      );

      // Press + three times without dismissing the keyboard.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();
      }

      // The field shows the new value, not a frozen 5.
      expect(value, 8);
      expect(find.text('8'), findsOneWidget);

      // Blurring must not commit a stale number and revert the presses.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(value, 8);
    },
  );

  testWidgets('typing a number and blurring commits it', (tester) async {
    var value = 5;
    await _pump(
      tester,
      initial: value,
      onChanged: (v) => value = v,
      current: () => value,
    );

    await tester.enterText(find.byType(TextField), '42');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(value, 42);
  });

  testWidgets('typing below the minimum clamps to 1 on blur', (tester) async {
    var value = 5;
    await _pump(
      tester,
      initial: value,
      onChanged: (v) => value = v,
      current: () => value,
    );

    await tester.enterText(find.byType(TextField), '0');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(value, 1);
    expect(find.text('1'), findsOneWidget);
  });
}
