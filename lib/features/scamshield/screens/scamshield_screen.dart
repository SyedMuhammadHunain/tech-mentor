import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_card.dart';

class ScamShieldScreen extends ConsumerStatefulWidget {
  const ScamShieldScreen({super.key});

  @override
  ConsumerState<ScamShieldScreen> createState() => _ScamShieldScreenState();
}

class _ScamShieldScreenState extends ConsumerState<ScamShieldScreen> {
  final _controller = TextEditingController();
  String? _result;
  bool _loading = false;
  bool _isDemo = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a message first.')),
      );
      return;
    }
    setState(() => _loading = true);
    final lang = ref.read(userPreferencesProvider).language;
    final result = await ref.read(aiServiceProvider).analyzeSuspiciousMessage(
          message: text,
          language: lang,
        );
    await ref
        .read(userPreferencesProvider.notifier)
        .markPracticeComplete('scamshield_check');
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result.text;
      _isDemo = result.isDemoFallback;
    });
  }

  void _loadSample() {
    _controller.text =
        'URGENT: Your bank account will be blocked today. Share your OTP now to keep it active. Click http://fake-bank-login.example';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScamShield')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Not Sure If A Message Is Real?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Paste a suspicious SMS or WhatsApp message. We will help you spot warning signs.',
            style: TextStyle(fontSize: 17, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TsCard(
            color: AppColors.simulationBanner,
            child: const Text(
              'We never claim a message is guaranteed safe. Always verify important financial messages through official channels. Suspicious links are never opened automatically.',
              style: TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste the SMS or WhatsApp message here…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TsButton(
            label: 'Use sample suspicious SMS',
            isPrimary: false,
            onPressed: _loadSample,
          ),
          const SizedBox(height: 12),
          TsButton(
            label: 'Analyse message',
            icon: Icons.shield_outlined,
            isLoading: _loading,
            onPressed: _analyze,
          ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            if (_isDemo)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Demo analysis mode',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            TsCard(
              child: Text(
                _result!,
                style: const TextStyle(fontSize: 17, height: 1.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
