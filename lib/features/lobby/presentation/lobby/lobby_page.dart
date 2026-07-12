import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/crypto/qr_payload.dart';
import '../../../../i18n/strings.g.dart';

/// Minimal lobby screen: just the scannable join QR. Issue #10 replaces
/// this with the full lobby (roster, live settings, start button); this
/// exists so the host flow (#8) has somewhere to land.
class LobbyPage extends StatelessWidget {
  const LobbyPage({required this.joinToken, required this.gameKey, super.key});

  final String joinToken;
  final Uint8List gameKey;

  @override
  Widget build(BuildContext context) {
    final payload = QrPayload(joinToken: joinToken, keyBytes: gameKey);
    return Scaffold(
      appBar: AppBar(title: Text(t.lobby.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.lobby.scanToJoin,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: QrImageView(
                  data: payload.encode(),
                  version: QrVersions.auto,
                  size: 260,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
