import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/session/resume_outcome.dart';
import '../../../core/session/session_resume_service.dart';
import '../../../i18n/strings.g.dart';

/// Renders normally on every build — a resumed session (#54) is rare (app
/// crash/close mid-game) and the check is fast, so this redirects shortly
/// after the first frame rather than gating the far more common "nothing
/// to resume" case behind a loading spinner.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    unawaited(_tryResume());
  }

  Future<void> _tryResume() async {
    final outcome = await getIt<SessionResumeService>().resume();
    if (!mounted) return;
    switch (outcome) {
      case ResumeToLobby():
        context.go('/lobby');
      case ResumeToIngame(:final initialEndsAt):
        context.go('/location-gate', extra: initialEndsAt);
      case ResumeNone():
      // Nothing to resume — the normal home screen is already showing.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.app.title,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () => context.push('/scan'),
                child: Text(t.home.joinGame),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.push('/host-setup'),
                child: Text(t.home.hostGame),
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () => _showGoodToKnow(context),
                child: Text(t.home.goodToKnowButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showGoodToKnow(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.goodToKnow.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _GoodToKnowSection(
                        title: t.goodToKnow.fairPlayTitle,
                        body: t.home.playFairDisclaimer,
                      ),
                      _GoodToKnowSection(
                        title: t.goodToKnow.privacyTitle,
                        body: t.goodToKnow.privacyBody,
                      ),
                      _GoodToKnowSection(
                        title: t.goodToKnow.moneyTitle,
                        body: t.goodToKnow.moneyBody,
                      ),
                      _GoodToKnowSection(
                        title: t.goodToKnow.aiTitle,
                        body: t.goodToKnow.aiBody,
                      ),
                      _GoodToKnowSection(
                        title: t.goodToKnow.beginnerTipsTitle,
                        body: t.goodToKnow.beginnerTipsBody,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoodToKnowSection extends StatelessWidget {
  const _GoodToKnowSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }
}
