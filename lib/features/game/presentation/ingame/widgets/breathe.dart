import 'package:flutter/material.dart';

/// Slowly fades [child] between [min] and [max] opacity and back, forever —
/// a reticle still hunting, an alarm still sounding. Ambient, not
/// informational, so it stops flat at [max] when the platform asks for
/// reduced motion (the state a glance needs is the visible one).
class Breathe extends StatefulWidget {
  const Breathe({
    required this.child,
    this.min = 0.35,
    this.max = 1.0,
    this.period = const Duration(milliseconds: 2200),
    super.key,
  });

  final Widget child;
  final double min;
  final double max;
  final Duration period;

  @override
  State<Breathe> createState() => _BreatheState();
}

class _BreatheState extends State<Breathe> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honour reduced motion, and re-check it if the setting changes while the
    // screen is up: run the loop, or park at full opacity.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(Tween(begin: widget.min, end: widget.max)),
      child: widget.child,
    );
  }
}
