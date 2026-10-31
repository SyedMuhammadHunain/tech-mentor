import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../data/models/user_preferences.dart';

class VoiceService {
  VoiceService() {
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) {
      debugPrint('TTS error: $msg');
      _isSpeaking = false;
    });
  }

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechReady = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  List<LocaleName> _locales = const [];

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get speechAvailable => _speechReady;

  Future<bool> initSpeech() async {
    try {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        debugPrint('Microphone permission denied');
        _speechReady = false;
        return false;
      }
      _speechReady = await _speech.initialize(
        onError: (e) {
          debugPrint('STT error: $e');
          _isListening = false;
        },
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') {
            _isListening = false;
          }
        },
      );
      if (_speechReady) {
        _locales = await _speech.locales();
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _speechReady = false;
    }
    return _speechReady;
  }

  String _resolveListenLocale(AppLanguage language) {
    final preferred = switch (language) {
      AppLanguage.urdu => ['ur_PK', 'ur-PK', 'ur_IN', 'ur-IN', 'ur'],
      AppLanguage.romanUrdu => ['en_US', 'en-US', 'en_GB', 'en'],
      AppLanguage.english => ['en_US', 'en-US', 'en_GB', 'en'],
    };
    for (final code in preferred) {
      final match = _locales.where(
        (l) =>
            l.localeId.toLowerCase() == code.toLowerCase() ||
            l.localeId.toLowerCase().startsWith(code.toLowerCase().split('_').first),
      );
      if (match.isNotEmpty) return match.first.localeId;
    }
    if (language == AppLanguage.urdu) {
      // Device may not ship Urdu STT; English locale still captures some words.
      final en = _locales.where((l) => l.localeId.toLowerCase().startsWith('en'));
      if (en.isNotEmpty) return en.first.localeId;
    }
    return preferred.first;
  }

  Future<void> startListening({
    required AppLanguage language,
    required void Function(String text) onResult,
    void Function(String partial)? onPartial,
  }) async {
    if (!_speechReady) {
      final ok = await initSpeech();
      if (!ok) return;
    }
    if (_isListening) {
      await stopListening();
    }
    await stopSpeaking();
    _isListening = true;
    final locale = _resolveListenLocale(language);
    debugPrint('Listening with locale: $locale');
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          _isListening = false;
        } else {
          onPartial?.call(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        localeId: locale,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  Future<String> _resolveTtsLanguage(AppLanguage language) async {
    final languages = await _tts.getLanguages;
    final available = <String>[];
    if (languages is List) {
      for (final item in languages) {
        available.add(item.toString());
      }
    }

    final preferred = switch (language) {
      AppLanguage.urdu => ['ur-PK', 'ur_PK', 'urd-pak', 'ur-IN', 'ur'],
      AppLanguage.romanUrdu => ['en-US', 'en_US', 'en-GB', 'en'],
      AppLanguage.english => ['en-US', 'en_US', 'en-GB', 'en'],
    };

    for (final code in preferred) {
      final hit = available.where(
        (a) => a.toLowerCase().replaceAll('_', '-') ==
                code.toLowerCase().replaceAll('_', '-') ||
            a.toLowerCase().startsWith(code.toLowerCase().split('-').first),
      );
      if (hit.isNotEmpty) return hit.first;
    }
    return preferred.first;
  }

  Future<void> speak(String text, AppLanguage language) async {
    if (text.trim().isEmpty) return;
    await stopSpeaking();
    _isSpeaking = true;
    try {
      await _tts.awaitSpeakCompletion(true);
      final lang = await _resolveTtsLanguage(language);
      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(0.4);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      // Strip markdown-ish noise for clearer speech.
      final cleaned = text
          .replaceAll(RegExp(r'[*_#>`]'), '')
          .replaceAll(RegExp(r'\n{2,}'), '. ')
          .trim();
      final result = await _tts.speak(cleaned);
      if (result != 1) {
        _isSpeaking = false;
      }
    } catch (e) {
      debugPrint('Speak failed: $e');
      _isSpeaking = false;
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  void dispose() {
    _speech.cancel();
    _tts.stop();
  }
}
