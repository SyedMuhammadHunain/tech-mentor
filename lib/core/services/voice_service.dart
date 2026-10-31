import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../data/models/user_preferences.dart';

class VoiceService {
  VoiceService() {
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);
  }

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechReady = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get speechAvailable => _speechReady;

  Future<bool> initSpeech() async {
    try {
      _speechReady = await _speech.initialize(
        onError: (e) => debugPrint('STT error: $e'),
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') {
            _isListening = false;
          }
        },
      );
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _speechReady = false;
    }
    return _speechReady;
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
    _isListening = true;
    final locale = switch (language) {
      AppLanguage.urdu => 'ur_PK',
      AppLanguage.romanUrdu => 'en_US',
      AppLanguage.english => 'en_US',
    };
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
        listenMode: ListenMode.confirmation,
        localeId: locale,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  Future<void> speak(String text, AppLanguage language) async {
    if (text.trim().isEmpty) return;
    await stopSpeaking();
    _isSpeaking = true;
    final lang = switch (language) {
      AppLanguage.urdu => 'ur-PK',
      AppLanguage.romanUrdu => 'en-US',
      AppLanguage.english => 'en-US',
    };
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
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
