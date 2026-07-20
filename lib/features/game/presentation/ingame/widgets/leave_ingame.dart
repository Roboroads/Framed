import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/confirmation_dialog.dart';
import '../../../../../i18n/strings.g.dart';
import '../ingame_bloc.dart';

/// Leave via [IngameBloc], confirmed first (#77, #92) — the server kills
/// you (cause 'left') and relinks the circle exactly like any other death
/// when still alive, or just ends the session once already dead. Shared
/// by the corner button, the back gesture (#82), and the death screen's
/// own leave button — same shape every time, just different copy.
Future<void> confirmAndLeaveIngame(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) => confirmAndLeave(
  context: context,
  title: title,
  message: message,
  confirmLabel: confirmLabel,
  onConfirmed: (context) async {
    final succeeded = await context.read<IngameBloc>().leave();
    // #88: the dialog above promises an immediate consequence (frame
    // judging stops / a relink, possibly ending the game) — surface it
    // when the server never actually confirmed that, rather than
    // navigating home as if it had.
    if (!succeeded && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.ingame.leaveNetworkWarning)));
    }
  },
);
