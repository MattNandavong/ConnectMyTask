import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class VoiceService {
  late stt.SpeechToText _speech;
  bool isListening = false;
  String _previousRecognizedText = '';

  VoiceService() {
    _speech = stt.SpeechToText();
  }

  Future<void> startListening({
    required Function(String newText) onResult,
    required VoidCallback onListeningStarted,
    required VoidCallback onListeningStopped,
  }) async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('🔊 onStatus: $val'),
      onError: (val) => print('❌ onError: $val'),
    );

    if (available) {
      isListening = true;
      _previousRecognizedText = '';
      onListeningStarted();

      _speech.listen(
        onResult: (val) {
          if (val.hasConfidenceRating && val.confidence > 0) {
            final newText = val.recognizedWords.replaceFirst(_previousRecognizedText, '').trim();
            onResult(newText);
            _previousRecognizedText = val.recognizedWords;
          }
        },
      );
    }
  }

  void stopListening(VoidCallback onStopped) {
    _speech.stop();
    isListening = false;
    onStopped();
  }
}
