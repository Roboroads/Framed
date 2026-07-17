import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/camera/in_app_camera_page.dart';
import '../../../../core/text/name_sanitizer.dart';
import '../../../../core/widgets/full_screen_photo_page.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Same domain #66 already set up for join links, GitHub Pages-hosted
/// (docs/privacy-policy/index.html).
const _privacyPolicyUrl = 'https://getframed.fun/privacy-policy';

/// Name + reference selfie, shared by the host flow (#8) and the join flow
/// (#9) — same widget, no separate bloc. Whoever embeds this owns the state
/// (name, selfie bytes) and passes it back down via [name]/[selfieBytes];
/// this widget is purely presentational.
///
/// Also carries the data-consent notice (IDEA.md "Privacy & GDPR": the
/// pre-join screen states what is collected and for how long, before the
/// selfie is taken).
class PreJoinForm extends StatefulWidget {
  const PreJoinForm({
    required this.name,
    required this.onNameChanged,
    required this.selfieBytes,
    required this.onSelfieChanged,
    this.nameError,
    super.key,
  });

  final String name;
  final ValueChanged<String> onNameChanged;
  final Uint8List? selfieBytes;
  final ValueChanged<Uint8List?> onSelfieChanged;

  /// Inline error under the name field — e.g. the join flow's `name_taken`
  /// response from the server. `null` when there's nothing to show.
  final String? nameError;

  @override
  State<PreJoinForm> createState() => _PreJoinFormState();
}

class _PreJoinFormState extends State<PreJoinForm> {
  late final _nameController = TextEditingController(text: widget.name);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _takeSelfie() async {
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => const InAppCameraPage()),
    );
    if (bytes == null) return;
    widget.onSelfieChanged(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: t.preJoin.nameLabel,
            errorText: widget.nameError,
          ),
          maxLength: maxDisplayNameLength,
          onChanged: widget.onNameChanged,
        ),
        Gap.lg,
        Text(
          t.preJoin.consentNotice,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => launchUrl(Uri.parse(_privacyPolicyUrl)),
            child: Text(
              t.preJoin.privacyPolicyLink,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Gap.lg,
        Text(
          t.preJoin.selfieHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Gap.sm,
        if (widget.selfieBytes != null)
          Center(
            child: SizedBox(
              height: 200,
              // Selfies are captured portrait — a full-width, fixed-height
              // box stretched the image sideways. Match the shape instead.
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: GestureDetector(
                  onTap: () =>
                      FullScreenPhotoPage.open(context, widget.selfieBytes!),
                  child: ClipRRect(
                    borderRadius: AppTheme.corner,
                    child: Image.memory(widget.selfieBytes!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
        Gap.sm,
        OutlinedButton.icon(
          onPressed: _takeSelfie,
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(
            widget.selfieBytes == null
                ? t.preJoin.takeSelfie
                : t.preJoin.retakeSelfie,
          ),
        ),
      ],
    );
  }
}
