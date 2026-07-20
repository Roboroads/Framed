import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/closable_dialog.dart';

/// A labelled integer setting: a name, an [i] that explains it, and a
/// −/type/＋ control. Used once per timing knob on the game-settings screen.
///
/// The number can be changed two ways — the buttons and the text field — and
/// keeping those two in step is the whole subtlety here (see [_step]).
class SettingStepper extends StatefulWidget {
  const SettingStepper({
    required this.label,
    required this.info,
    required this.value,
    required this.unit,
    required this.onChanged,
    super.key,
  });

  static const _min = 1;

  final String label;
  final String info;
  final int value;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  State<SettingStepper> createState() => _SettingStepperState();
}

class _SettingStepperState extends State<SettingStepper> {
  late final _controller = TextEditingController(text: '${widget.value}');
  late final _focusNode = FocusNode()..addListener(_onFocusChange);

  @override
  void didUpdateWidget(covariant SettingStepper old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && !_focusNode.hasFocus) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    final typed = int.tryParse(_controller.text);
    final clamped = (typed ?? widget.value) < SettingStepper._min
        ? SettingStepper._min
        : (typed ?? widget.value);
    if (clamped != widget.value) widget.onChanged(clamped);
    _controller.text = '$clamped';
  }

  // The +/- path has to write the controller itself. didUpdateWidget refuses
  // to sync while the field has focus (so it can't clobber mid-type), and an
  // IconButton doesn't steal focus on touch — so a host who taps into the
  // field and then presses + would see the number freeze while the bloc value
  // climbed, and blurring would then commit the stale on-screen number and
  // silently undo every press. Writing here keeps display and value in step.
  void _step(int delta) {
    final next = widget.value + delta;
    if (next < SettingStepper._min) return;
    _controller.text = '$next';
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          // Expanded, not Flexible: Flexible sizes to the text, so the icon
          // hugged the end of each label and landed at a different x on every
          // row. Expanded pushes it to a fixed right edge, so the column of
          // icons reads as a column.
          Expanded(child: Text(widget.label)),
          HGap.xs,
          _InfoIcon(message: widget.info),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: widget.value > SettingStepper._min
                ? () => _step(-1)
                : null,
          ),
          SizedBox(
            width: 72,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _focusNode.unfocus(),
              // A number, so the data face with tabular figures: these tick
              // between 1 and 2 digits as you press, and a proportional font
              // makes the field twitch on every step.
              style: AppTheme.mono(Theme.of(context).textTheme.bodyLarge!),
              // `border: InputBorder.none` alone isn't enough against a global
              // inputDecorationTheme: it clears `border` but leaves the
              // theme's fill and its 16px content padding, which squeeze the
              // number and its unit out of a 72px-wide field entirely.
              // collapsed drops both.
              //
              // The theme's outline survives (collapsed leaves the per-state
              // borders alone) and is left that way on purpose — it's the only
              // thing marking this as type-able rather than as a label between
              // two buttons.
              decoration: InputDecoration.collapsed(
                hintText: null,
              ).copyWith(isDense: true, suffixText: widget.unit),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _step(1),
          ),
        ],
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => ClosableDialog(child: Text(message)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.xs),
        child: Icon(
          Icons.info_outline,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
