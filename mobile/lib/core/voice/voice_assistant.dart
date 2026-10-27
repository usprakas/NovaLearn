import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps on-device speech-to-text and text-to-speech behind one small API, so every screen that
/// wants a mic button and a "read this aloud" button doesn't reimplement init/listen/speak. Both
/// packages run entirely on-device (or, on web, through the browser's own Web Speech API) — no
/// backend call, no API key, per the Phase 6 plan's call-out that this is the one voice feature
/// that isn't blocked by a missing credential.
class VoiceAssistant {
  VoiceAssistant()
      : _speech = SpeechToText(),
        _tts = FlutterTts();

  final SpeechToText _speech;
  final FlutterTts _tts;
  bool _speechReady = false;
  void Function()? _onStoppedListening;

  bool get isListening => _speech.isListening;

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) return true;
    // onStatus is registered once here, but _onStoppedListening is reassigned on every
    // startListening call below, so this closure always calls whichever screen is current —
    // not just whichever screen happened to be listening the first time this engine was used.
    _speechReady = await _speech.initialize(onStatus: (String status) {
      if (status == 'notListening' || status == 'done') {
        _onStoppedListening?.call();
      }
    });
    return _speechReady;
  }

  /// Starts listening and calls [onResult] with the live-updating recognized text as the child
  /// speaks, and whether that particular result is final. [onStoppedListening] is the more
  /// reliable "recognition has actually stopped" signal — on web, a final result doesn't
  /// consistently arrive when the browser's Web Speech API auto-stops after silence, but the
  /// engine's status always transitions to 'notListening'/'done' when that happens. Returns false
  /// without calling either callback if speech recognition isn't available at all (unsupported
  /// browser/platform, or the microphone permission was denied).
  Future<bool> startListening(
    void Function(String text, bool isFinal) onResult, {
    void Function()? onStoppedListening,
  }) async {
    _onStoppedListening = onStoppedListening;
    if (!await _ensureSpeechReady()) return false;
    await _speech.listen(
        onResult: (SpeechRecognitionResult result) =>
            onResult(result.recognizedWords, result.finalResult));
    return true;
  }

  Future<void> stopListening() => _speech.stop();

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() => _tts.stop();

  void dispose() {
    _speech.stop();
    _tts.stop();
  }
}
