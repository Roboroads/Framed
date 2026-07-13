import 'package:postgrest/postgrest.dart';

/// The stable error codes raised by `submit_frame`
/// (backend/volumes/db/init/19-frames.sql), as
/// `raise exception using message = 'code'`, surfaced via
/// [PostgrestException.message].
enum FrameError {
  wrongStatus('wrong_status'),
  onCooldown('on_cooldown'),
  frameAlreadyPending('frame_already_pending'),
  notFound('not_found'),
  notMember('not_member'),
  unknown('');

  const FrameError(this.code);

  final String code;

  static FrameError fromException(Object error) {
    if (error is! PostgrestException) return unknown;
    return values.firstWhere(
      (e) => e != unknown && e.code == error.message,
      orElse: () => unknown,
    );
  }
}
