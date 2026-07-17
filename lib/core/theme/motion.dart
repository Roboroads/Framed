import 'package:flutter/material.dart';

/// The app's motion vocabulary: how long things take, and how they ease.
///
/// **House rule: every animation gates on [Motion.gate].** Not "every
/// decorative animation" — every one. `MediaQuery.disableAnimationsOf` is a
/// user telling the OS that motion makes them ill or makes the interface
/// unusable, and a game played while walking around outdoors is the last
/// place to argue with them. `FramedWordmark` set this precedent; this turns
/// it into something the rest of the app inherits rather than re-decides.
///
/// The durations are few on purpose. Three speeds and one signature is
/// enough to feel deliberate; a dozen just feels arbitrary.
abstract final class Motion {
  /// A control acknowledging a touch. Below ~150ms reads as instant response
  /// rather than as an animation, which is the point.
  static const quick = Duration(milliseconds: 120);

  /// The default: something on screen becoming something else.
  static const standard = Duration(milliseconds: 200);

  /// The signature: the reticle locking onto the wordmark. Long enough to
  /// read as a camera finding focus rather than as a logo sliding in. Used
  /// once, on the screen that opens the app.
  static const lock = Duration(milliseconds: 900);

  /// Things arriving: fast at first, settling at the end. The same shape as
  /// autofocus catching — which is the app's whole visual idea.
  static const enter = Curves.easeOutCubic;

  /// [d], or nothing at all if the platform asked for less motion.
  ///
  /// Zero rather than merely shorter: a reduced-motion user wants the end
  /// state, not a faster trip to it.
  static Duration gate(BuildContext context, Duration d) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}

/// The transition between screens: the next one settles into focus.
///
/// A fade with a whisper of scale, not a slide. Framed is looked *through* —
/// the mark is a viewfinder — so screens resolve the way a lens finds its
/// subject rather than sliding past like cards. The scale is 1.02, which
/// nobody will consciously notice, and that's correct: it should register as
/// "this app feels considered", never as "look at this transition".
///
/// This is a [PageTransitionsBuilder] rather than a `CustomTransitionPage`
/// per route, for one blunt reason: `CustomTransitionPage` builds a plain
/// route with none of the platform behaviour `MaterialPage` mixes in — most
/// importantly iOS's interactive back-swipe. Trading a system-wide
/// navigation gesture for a fade would be a bad deal, and screens with no
/// app-bar back button would become dead ends. Living in the theme also
/// means a route added later can't forget to opt in.
///
/// iOS keeps its native transition (see [AppTheme]): the swipe and the
/// parallax slide are one gesture there, and half of it would feel broken.
class FocusPageTransitionsBuilder extends PageTransitionsBuilder {
  const FocusPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // The route's duration is fixed by the framework, so reduced motion is
    // honoured by handing over the finished page immediately rather than by
    // shortening anything.
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return _FocusTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// A widget, not a bare `FadeTransition` built inline, so the
/// [CurvedAnimation]s are created once and disposed with the route instead of
/// leaking a listener per frame.
class _FocusTransition extends StatefulWidget {
  const _FocusTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  State<_FocusTransition> createState() => _FocusTransitionState();
}

class _FocusTransitionState extends State<_FocusTransition> {
  late CurvedAnimation _in;
  late CurvedAnimation _out;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(_FocusTransition old) {
    super.didUpdateWidget(old);
    if (old.animation != widget.animation ||
        old.secondaryAnimation != widget.secondaryAnimation) {
      _in.dispose();
      _out.dispose();
      _bind();
    }
  }

  void _bind() {
    _in = CurvedAnimation(parent: widget.animation, curve: Motion.enter);
    _out = CurvedAnimation(
      parent: widget.secondaryAnimation,
      curve: Motion.enter,
    );
  }

  @override
  void dispose() {
    _in.dispose();
    _out.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The outgoing page pulls back rather than sitting there: focus moved to
    // something else, so it gives up a little scale and light on the way out.
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.4).animate(_out),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.98).animate(_out),
        child: FadeTransition(
          opacity: _in,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.02, end: 1).animate(_in),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
