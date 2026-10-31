import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_card.dart';

class ScreenExplainerScreen extends ConsumerStatefulWidget {
  const ScreenExplainerScreen({super.key});

  @override
  ConsumerState<ScreenExplainerScreen> createState() =>
      _ScreenExplainerScreenState();
}

class _ScreenExplainerScreenState extends ConsumerState<ScreenExplainerScreen> {
  Uint8List? _bytes;
  String? _mime;
  String? _explanation;
  bool _loading = false;
  bool _isDemo = false;
  bool _privacyAccepted = false;

  Future<void> _pick() async {
    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm you hid sensitive information first.'),
        ),
      );
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _bytes = bytes;
      _mime = file.mimeType ?? 'image/jpeg';
      _explanation = null;
    });
  }

  Future<void> _explain() async {
    if (_bytes == null) return;
    setState(() => _loading = true);
    final lang = ref.read(userPreferencesProvider).language;
    final result = await ref.read(aiServiceProvider).explainScreenshot(
          imageBytes: _bytes!,
          language: lang,
          mimeType: _mime,
        );
    await ref
        .read(userPreferencesProvider.notifier)
        .markPracticeComplete('explain_screen');
    if (!mounted) return;
    setState(() {
      _loading = false;
      _explanation = result.text;
      _isDemo = result.isDemoFallback;
    });
  }

  void _clearImage() {
    setState(() {
      _bytes = null;
      _explanation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explain My Screen')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Don't Understand Your Screen?",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let TechSaathi Explain It.',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TsCard(
            color: AppColors.simulationBanner,
            child: const Text(
              'Please hide passwords, OTPs, PINs, account numbers and other sensitive information before uploading. Screenshots are not stored permanently.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _privacyAccepted,
            onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
            title: const Text(
              'I have hidden sensitive information',
              style: TextStyle(fontSize: 16),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),
          TsButton(
            label: 'Select screenshot from gallery',
            icon: Icons.photo_library_outlined,
            onPressed: _pick,
          ),
          if (_bytes != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(_bytes!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TsButton(
                    label: 'Explain this screen',
                    isLoading: _loading,
                    onPressed: _explain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TsButton(
              label: 'Remove image',
              isPrimary: false,
              onPressed: _clearImage,
            ),
          ],
          if (_explanation != null) ...[
            const SizedBox(height: 20),
            if (_isDemo)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Demo explanation (connect Gemini API key for live image analysis)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            TsCard(
              child: Text(
                _explanation!,
                style: const TextStyle(fontSize: 17, height: 1.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
