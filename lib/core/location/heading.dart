import 'package:flutter_compass/flutter_compass.dart';

/// Wraps flutter_compass (#17) so a package swap later touches one file.
class Heading {
  /// Device heading in degrees (0-360, 0 = north). Devices with no usable
  /// sensor simply never emit — callers fall back to text after a timeout.
  Stream<double> get stream =>
      FlutterCompass.events
          ?.map((e) => e.heading)
          .where((h) => h != null)
          .cast<double>() ??
      const Stream.empty();
}
