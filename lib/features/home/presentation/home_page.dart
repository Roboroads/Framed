import 'package:flutter/material.dart';

import '../../../i18n/strings.g.dart';
import '../../lobby/presentation/host_setup/host_setup_page.dart';
import '../../lobby/presentation/scan/scan_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ScanPage())),
                child: Text(t.home.joinGame),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HostSetupPage()),
                ),
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
