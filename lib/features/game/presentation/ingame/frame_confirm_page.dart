import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;

import '../../../../core/camera/in_app_camera_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/motion.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/util/uuid.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/frame_error.dart';
import 'ingame_bloc.dart';
import 'widgets/reticle_frame.dart';
import 'widgets/tappable_photo.dart';

/// Confirm/retake screen for a just-captured frame photo (#21).
///
/// The photo is a physical object here: pick it up and fling it — up sends
/// it to the judges, down discards it for a retake. The card follows the
/// finger on both axes with a slight tilt, and flies off along the actual
/// release vector, so a hard diagonal throw looks like one. Only *vertical*
/// travel/velocity decides the outcome though; sideways motion is
/// expressiveness, not a third action. The two direction labels are also
/// tap targets (they run the same fling), so the gesture is never the only
/// way to act.
///
/// [_frameUuid] is generated once and reused across retries of a failed
/// submit — the repository upserts to that same storage path, so a retry
/// after a dropped connection never orphans a partial upload (see #21's
/// storage policy note). Retaking the photo replaces this whole page
/// (a fresh capture gets a fresh uuid).
class FrameConfirmPage extends StatefulWidget {
  const FrameConfirmPage({
    required this.photoBytes,
    required this.bloc,
    super.key,
  });

  final Uint8List photoBytes;
  final IngameBloc bloc;

  @override
  State<FrameConfirmPage> createState() => _FrameConfirmPageState();
}

class _FrameConfirmPageState extends State<FrameConfirmPage>
    with SingleTickerProviderStateMixin {
  final _frameUuid = generateUuidV4();
  bool _submitting = false;
  FrameError? _error;

  /// Where the card currently sits relative to its resting spot. Written
  /// directly during a drag, and by [_settleAnim] on release.
  Offset _drag = Offset.zero;

  /// True from the moment a fling commits until the card is back — blocks
  /// gestures and buttons while the card is (heading) off-screen.
  bool _flung = false;

  late final AnimationController _settle = AnimationController(vsync: this);
  Animation<Offset>? _settleAnim;

  // Sending a frame is one-way (it opens a vote on a photo of a real
  // person), so up commits at a higher bar than the cheap, recoverable
  // retake below.
  static const _upTravelFraction = 0.25;
  static const _downTravelFraction = 0.18;
  static const _upVelocity = -1000.0;
  static const _downVelocity = 700.0;

  /// Max tilt (radians, ≈8°) reached [_tiltReach] px off-center — a held
  /// photo canting in the hand, not a spinning card.
  static const _maxTilt = 0.14;
  static const _tiltReach = 200.0;

  double get _tilt => _maxTilt * (_drag.dx / _tiltReach).clamp(-1.0, 1.0);

  @override
  void initState() {
    super.initState();
    _settle.addListener(() {
      setState(() => _drag = _settleAnim!.value);
    });
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  bool get _gestureLocked => _submitting || _flung;

  void _onPanStart(DragStartDetails details) {
    if (_gestureLocked) return;
    _settle.stop(); // catch the card mid-spring-back
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_gestureLocked) return;
    setState(() => _drag += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_gestureLocked) return;
    final height = MediaQuery.sizeOf(context).height;
    final v = details.velocity.pixelsPerSecond;
    // A commit needs either enough travel (without a hard flick back the
    // other way) or a decisive fling in that direction.
    final commitUp =
        (_drag.dy < -_upTravelFraction * height && v.dy < 300) ||
        (v.dy < _upVelocity && _drag.dy < 0);
    final commitDown =
        (_drag.dy > _downTravelFraction * height && v.dy > -300) ||
        (v.dy > _downVelocity && _drag.dy > 0);
    if (commitUp) {
      _flingOff(v, up: true);
    } else if (commitDown) {
      _flingOff(v, up: false);
    } else {
      _springBack();
    }
  }

  /// Animate [_drag] to [to]; resolves early (mid-flight) if a new drag
  /// catches the card, in which case the caller's continuation is skipped
  /// by the [_flung]/mounted guards.
  Future<void> _animateDrag(
    Offset to, {
    required Duration duration,
    required Curve curve,
  }) async {
    _settleAnim = Tween(
      begin: _drag,
      end: to,
    ).animate(CurvedAnimation(parent: _settle, curve: curve));
    _settle.duration = Motion.gate(context, duration);
    await _settle.forward(from: 0);
  }

  void _springBack() {
    // easeOutBack overshoots the resting point a touch — the spring.
    _animateDrag(
      Offset.zero,
      duration: Motion.settle,
      curve: Curves.easeOutBack,
    );
  }

  /// Fly off along the release vector (or straight up/down for a slow
  /// travel-commit), then run the committed action.
  Future<void> _flingOff(Offset velocity, {required bool up}) async {
    setState(() => _flung = true);
    var dir = velocity.distance > 400
        ? velocity / velocity.distance
        : Offset(0, up ? -1 : 1);
    // The throw's vertical sign must match the committed action — a
    // travel-commit released with a slight counter-flick still leaves the
    // right way.
    if (up != dir.dy < 0) dir = Offset(0, up ? -1 : 1);
    final height = MediaQuery.sizeOf(context).height;
    await _animateDrag(
      _drag + dir * (height * 1.2),
      duration: Motion.standard,
      curve: Curves.easeOut,
    );
    // The route can stop being current during the flight — the user hit
    // back within the fling window. Honor the back press: don't submit
    // (one-way) and don't push a camera onto whatever they backed into.
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    if (up) {
      await _submit();
    } else {
      final canceled = await _retake();
      if (canceled && mounted) _returnCard();
    }
  }

  /// Tap path for the two labels: same fling as the gesture, straight
  /// up/down (zero release velocity).
  void _actFromTap({required bool up}) {
    if (_gestureLocked) return;
    _flingOff(Offset.zero, up: up);
  }

  /// Bring a flung card back — a failed submit or a canceled retake.
  void _returnCard() {
    setState(() => _flung = false);
    _animateDrag(
      Offset.zero,
      duration: Motion.settle,
      curve: Curves.easeOutCubic,
    );
  }

  /// Returns true if the user backed out of the camera without a capture.
  Future<bool> _retake() async {
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) =>
            const InAppCameraPage(lensDirection: CameraLensDirection.back),
      ),
    );
    if (bytes == null || !mounted) return true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FrameConfirmPage(photoBytes: bytes, bloc: widget.bloc),
      ),
    );
    return false;
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await widget.bloc.submitFrame(
      photoBytes: widget.photoBytes,
      frameUuid: _frameUuid,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _submitting = false;
      _error = error;
    });
    if (_flung) _returnCard();
  }

  String _errorText(FrameError error) => switch (error) {
    FrameError.onCooldown => t.frame.errorOnCooldown,
    FrameError.frameAlreadyPending => t.frame.errorAlreadyPending,
    FrameError.wrongStatus => t.frame.errorWrongStatus,
    _ => t.frame.errorGeneric,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height;
    // How close each release direction is to committing (0..1) — drives
    // the hints brightening and the reticle arming toward crimson, so you
    // feel which action will fire before letting go.
    final upProgress = (-_drag.dy / (_upTravelFraction * height)).clamp(
      0.0,
      1.0,
    );
    final downProgress = (_drag.dy / (_downTravelFraction * height)).clamp(
      0.0,
      1.0,
    );
    final reticleColor = Color.lerp(
      theme.colorScheme.onSurfaceVariant,
      theme.colorScheme.primary,
      upProgress,
    )!;

    return Scaffold(
      appBar: AppBar(title: Text(t.frame.confirmTitle)),
      body: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SwipeHint(
              icon: Icons.keyboard_double_arrow_up,
              text: t.frame.sendToJudges,
              progress: _flung ? 0 : upProgress,
              armedColor: theme.colorScheme.primary,
              onPressed: _gestureLocked ? null : () => _actFromTap(up: true),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (_flung && _submitting)
                    const Center(child: CircularProgressIndicator()),
                  Center(
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      // A system-canceled pointer (notification shade,
                      // back-gesture takeover) fires cancel, not end —
                      // without this the card would strand mid-air.
                      onPanCancel: () {
                        if (!_gestureLocked) _springBack();
                      },
                      child: Transform.translate(
                        offset: _drag,
                        child: Transform.rotate(
                          angle: _tilt,
                          // Screen readers intercept swipes, so the throw
                          // is exposed as two custom actions; the labels
                          // below remain the primary accessible path.
                          child: Semantics(
                            customSemanticsActions: {
                              CustomSemanticsAction(
                                label: t.frame.sendToJudges,
                              ): () =>
                                  _actFromTap(up: true),
                              CustomSemanticsAction(
                                label: t.frame.retake,
                              ): () =>
                                  _actFromTap(up: false),
                            },
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: AspectRatio(
                                aspectRatio: 3 / 4,
                                child: ReticleFrame(
                                  color: reticleColor,
                                  child: TappablePhoto(
                                    bytes: widget.photoBytes,
                                    radius: 8,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Overlaid rather than a Column child so appearing text
                  // never reflows the card's resting spot or overflows a
                  // short (landscape) screen.
                  if (_error case final error?)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.lg,
                            vertical: Space.sm,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: AppTheme.corner,
                          ),
                          child: Text(
                            _errorText(error),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _SwipeHint(
              icon: Icons.keyboard_double_arrow_down,
              text: t.frame.retake,
              progress: _flung ? 0 : downProgress,
              armedColor: theme.colorScheme.onSurface,
              onPressed: _gestureLocked ? null : () => _actFromTap(up: false),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the two direction cues, faint at rest; brightens (and for send,
/// tints crimson) as the drag approaches that direction's commit threshold.
/// Also a real button — the tap path runs the same action as the fling, so
/// the gesture is never the only way (a11y, and plain discoverability).
class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.icon,
    required this.text,
    required this.progress,
    required this.armedColor,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final double progress;
  final Color armedColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Full onSurfaceVariant at rest, not a faded whisper — with the old
    // button row gone these two ARE the visible controls, so they have to
    // pass contrast on their own. Arming still brightens them further.
    final restColor = theme.colorScheme.onSurfaceVariant;
    final color = Color.lerp(restColor, armedColor, progress)!;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}
