import 'dart:async';

import 'package:flutter/material.dart';

/// Ticks once a second and renders the mm:ss remaining until [deadline] —
/// shared by the warning overlay and the dispersal countdown, the only two
/// places that need a live countdown.
class CountdownText extends StatefulWidget {
  const CountdownText({required this.deadline, required this.builder, super.key});

  final DateTime deadline;
  final Widget Function(BuildContext context, String time) builder;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.deadline.difference(DateTime.now());
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final minutes = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');
    return widget.builder(context, '$minutes:$seconds');
  }
}
