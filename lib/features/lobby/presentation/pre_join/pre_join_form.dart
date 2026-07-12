import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../i18n/strings.g.dart';

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
    super.key,
  });

  final String name;
  final ValueChanged<String> onNameChanged;
  final Uint8List? selfieBytes;
  final ValueChanged<Uint8List?> onSelfieChanged;

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
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (photo == null) return;
    widget.onSelfieChanged(await photo.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: t.preJoin.nameLabel),
          onChanged: widget.onNameChanged,
        ),
        const SizedBox(height: 16),
        Text(
          t.preJoin.consentNotice,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        if (widget.selfieBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              widget.selfieBytes!,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 8),
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
