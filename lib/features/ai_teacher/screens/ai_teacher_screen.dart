import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/user_preferences.dart';

class ChatMessage {
  ChatMessage({required this.text, required this.isUser, this.isDemo = false});
  final String text;
  final bool isUser;
  final bool isDemo;
}

class AiTeacherScreen extends ConsumerStatefulWidget {
  const AiTeacherScreen({super.key});

  @override
  ConsumerState<AiTeacherScreen> createState() => _AiTeacherScreenState();
}

class _AiTeacherScreenState extends ConsumerState<AiTeacherScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  bool _listening = false;
  bool _welcomeSet = false;
  String? _lastAnswer;
  bool _lastWasDemo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(appStringsProvider);
      if (!_welcomeSet) {
        setState(() {
          _messages.add(ChatMessage(text: s.aiWelcome, isUser: false));
          _welcomeSet = true;
        });
      }
      ref.read(voiceServiceProvider).initSpeech();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _loading = true;
      _controller.clear();
    });
    _scrollToEnd();

    final user = ref.read(userPreferencesProvider);
    final result = await ref.read(aiServiceProvider).askTechnologyQuestion(
          question: text,
          language: user.language,
        );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _lastAnswer = result.text;
      _lastWasDemo = result.isDemoFallback;
      _messages.add(
        ChatMessage(
          text: result.text,
          isUser: false,
          isDemo: result.isDemoFallback,
        ),
      );
    });
    _scrollToEnd();

    if (user.voiceEnabled &&
        (user.learningStyle == LearningStyle.voice ||
            user.learningStyle == LearningStyle.both ||
            user.learningStyle == LearningStyle.stepByStepText)) {
      // Always offer spoken answer when voice is enabled.
      await ref.read(voiceServiceProvider).speak(result.text, user.language);
    }
  }

  Future<void> _toggleListen() async {
    final voice = ref.read(voiceServiceProvider);
    final user = ref.read(userPreferencesProvider);
    final s = ref.read(appStringsProvider);
    if (_listening) {
      await voice.stopListening();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ok = await voice.initSpeech();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.micUnavailable)),
      );
      return;
    }
    setState(() => _listening = true);
    await voice.startListening(
      language: user.language,
      onResult: (text) {
        if (!mounted) return;
        setState(() => _listening = false);
        if (text.trim().isNotEmpty) {
          _controller.text = text;
          _send(text);
        }
      },
      onPartial: (text) {
        if (!mounted) return;
        setState(() => _controller.text = text);
      },
    );
  }

  Future<void> _repeat() async {
    final answer = _lastAnswer;
    if (answer == null) return;
    final user = ref.read(userPreferencesProvider);
    await ref.read(voiceServiceProvider).speak(answer, user.language);
  }

  Future<void> _stopSpeaking() async {
    await ref.read(voiceServiceProvider).stopSpeaking();
  }

  void _clear() {
    final s = ref.read(appStringsProvider);
    setState(() {
      _messages
        ..clear()
        ..add(ChatMessage(text: s.aiWelcome, isUser: false));
      _lastAnswer = null;
      _lastWasDemo = false;
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    final lang = ref.watch(userPreferencesProvider).language;
    final hasKey = ref.watch(aiServiceProvider).hasLiveModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.aiTeacher),
        actions: [
          IconButton(
            tooltip: 'Stop speaking',
            onPressed: _stopSpeaking,
            icon: const Icon(Icons.stop_circle_outlined),
          ),
          IconButton(
            tooltip: 'Repeat answer',
            onPressed: _repeat,
            icon: const Icon(Icons.volume_up_outlined),
          ),
          IconButton(
            tooltip: 'Clear chat',
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!hasKey || _lastWasDemo)
            Container(
              width: double.infinity,
              color: AppColors.simulationBanner,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                !hasKey
                    ? 'Gemini key missing — using offline answers.'
                    : (_lastWasDemo
                        ? 'Live Gemini failed for last reply — offline answer shown.'
                        : ''),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loading && index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        const SizedBox(width: 12),
                        Text(s.thinking, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.88,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? AppColors.primary
                          : AppColors.secondaryBg,
                      borderRadius: BorderRadius.circular(16),
                      border: msg.isUser
                          ? null
                          : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      msg.text,
                      textDirection:
                          lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.45,
                        color:
                            msg.isUser ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final q in s.suggestedQuestions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(q, style: const TextStyle(fontSize: 14)),
                      onPressed: _loading ? null : () => _send(q),
                      backgroundColor: AppColors.secondaryTeal,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: _listening ? 'Stop' : s.voice,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(56, 56),
                      backgroundColor: _listening
                          ? AppColors.danger
                          : AppColors.secondaryTeal,
                      foregroundColor:
                          _listening ? Colors.white : AppColors.primary,
                    ),
                    onPressed: _toggleListen,
                    icon: Icon(
                      _listening ? Icons.mic : Icons.mic_none,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: s.typeQuestion,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send',
                    style: IconButton.styleFrom(
                      minimumSize: const Size(56, 56),
                    ),
                    onPressed: _loading ? null : () => _send(),
                    icon: const Icon(Icons.send, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
