import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/push/push_service.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/widgets/pinned_action_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import '../pre_join/pre_join_form.dart';
import 'join_cubit.dart';
import 'join_state.dart';
import '../../../../core/theme/spacing.dart';

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
        pushService: getIt<PushService>(),
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
            context.go('/lobby');
          } else if (state.status == JoinStatus.failure &&
              state.error != LobbyError.nameTaken) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(t.join.errorGeneric)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<JoinCubit>();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Space.xl,
                    Space.lg,
                    Space.xl,
                    Space.xl,
                  ),
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
                  ],
                ),
              ),
              PinnedActionBar(
                child: FilledButton(
                  onPressed: state.canSubmit ? cubit.submit : null,
                  child: state.status == JoinStatus.submitting
                      ? const ButtonSpinner()
                      : Text(t.join.joinButton),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
