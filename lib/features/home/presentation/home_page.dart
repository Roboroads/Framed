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
              Text(
                t.home.playFairDisclaimer,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
