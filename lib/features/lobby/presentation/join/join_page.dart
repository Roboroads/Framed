import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/session/game_session.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import '../lobby/lobby_page.dart';
import '../pre_join/pre_join_form.dart';
import 'join_cubit.dart';
import 'join_state.dart';

class JoinPage extends StatelessWidget {
  const JoinPage({
    required this.joinToken,
    required this.gameKeyBytes,
    super.key,
  });

  final String joinToken;
  final Uint8List gameKeyBytes;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JoinCubit(
        repository: getIt<LobbyRepository>(),
        session: getIt<GameSession>(),
        joinToken: joinToken,
        gameKeyBytes: gameKeyBytes,
      ),
      child: _JoinView(joinToken: joinToken, gameKeyBytes: gameKeyBytes),
    );
  }
}

class _JoinView extends StatelessWidget {
  const _JoinView({required this.joinToken, required this.gameKeyBytes});

  final String joinToken;
  final Uint8List gameKeyBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.preJoin.title)),
      body: BlocConsumer<JoinCubit, JoinState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == JoinStatus.success) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    LobbyPage(joinToken: joinToken, gameKey: gameKeyBytes),
              ),
            );
          } else if (state.status == JoinStatus.failure &&
              state.error != LobbyError.nameTaken) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(t.join.errorGeneric)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<JoinCubit>();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PreJoinForm(
                name: state.name,
                onNameChanged: cubit.nameChanged,
                selfieBytes: state.selfieBytes,
                onSelfieChanged: cubit.selfieChanged,
                nameError: state.error == LobbyError.nameTaken
                    ? t.join.errorNameTaken
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.canSubmit ? cubit.submit : null,
                child: state.status == JoinStatus.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.join.joinButton),
              ),
            ],
          );
        },
      ),
    );
  }
}
