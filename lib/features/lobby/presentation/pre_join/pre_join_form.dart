import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/camera/in_app_camera_page.dart';
import '../../../../core/text/name_sanitizer.dart';
import '../../../../core/widgets/full_screen_photo_page.dart';
import '../../../../core/widgets/section_header.dart';
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(t.preJoin.nameSectionTitle),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: t.preJoin.nameLabel,
            errorText: widget.nameError,
          ),
          maxLength: maxDisplayNameLength,
          onChanged: widget.onNameChanged,
        ),
        Gap.md,
        SectionHeader(t.preJoin.faceSectionTitle),
        Text(t.preJoin.selfieHint, style: theme.textTheme.bodySmall),
        Gap.md,
        if (widget.selfieBytes != null) ...[
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
          Gap.md,
        ],
        OutlinedButton.icon(
          onPressed: _takeSelfie,
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(
            widget.selfieBytes == null
                ? t.preJoin.takeSelfie
                : t.preJoin.retakeSelfie,
          ),
        ),
        Gap.xl,

        // Two sections, because these are two unrelated promises. One is a
        // legal disclosure about what leaves your phone; the other is "don't
        // walk into traffic". They used to be one paragraph, which made each
        // of them easier to skim past, and left the notice inheriting the
        // "Your name" header above it as though it were a footnote about
        // that one field.
        //
        // Both sit directly above the button that acts on them. Nothing
        // leaves the device until it's pressed — the selfie is captured
        // locally, and joining is the consent action — so this is the point
        // where the notice is actually load-bearing. Wording is tracked
        // against the privacy policy in docs/release-checklist.md.
        SectionHeader(t.preJoin.sharesSectionTitle),
        Text(t.preJoin.consentNotice, style: theme.textTheme.bodySmall),
        Gap.xs,
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => launchUrl(Uri.parse(_privacyPolicyUrl)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Text(
                t.preJoin.privacyPolicyLink,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
        Gap.xl,

        SectionHeader(t.preJoin.playSafeSectionTitle),
        Text(t.preJoin.playSafeNotice, style: theme.textTheme.bodySmall),
        Gap.md,
        Text(
          t.preJoin.agreeNotice,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
