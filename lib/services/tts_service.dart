// This service will handle text-to-speech functionality.
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  List<Map<String, String>> _voices = [];
  String? _selectedVoice;

  TtsService() {
    _flutterTts = FlutterTts();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    // Basic TTS setup
    // Set language (optional, defaults to system language)
    // await _flutterTts.setLanguage("en-US");

    // Set speech rate (optional, 0.0 to 1.0)
    // await _flutterTts.setSpeechRate(0.5);

    // Set volume (optional, 0.0 to 1.0)
    // await _flutterTts.setVolume(1.0);

    // Set pitch (optional, 0.5 to 2.0)
    // await _flutterTts.setPitch(1.0);

    // Get available voices (optional)
    try {
      var voices = await _flutterTts.getVoices;
      if (voices != null) {
        _voices = List<Map<String, String>>.from(
          voices.map(
            (voice) => {
              'name': voice['name'] as String,
              'locale': voice['locale'] as String,
            },
          ),
        );
        // Optionally select a specific voice, e.g., an English voice
        _selectedVoice =
            _voices.firstWhere(
              (voice) => voice['locale']?.startsWith('en') ?? false,
              orElse: () => _voices.isNotEmpty ? _voices.first : {'name': ''},
            )['name'];
        if (_selectedVoice != null && _selectedVoice!.isNotEmpty) {
          await _flutterTts.setVoice({
            'name': _selectedVoice!,
            'locale':
                _voices.firstWhere(
                  (v) => v['name'] == _selectedVoice,
                )['locale']!,
          });
        }
      }
    } catch (e) {
      print("Error getting TTS voices: $e");
    }

    _flutterTts.setCompletionHandler(() {
      print("TTS playback completed.");
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
    });

    _isInitialized = true;
    print(
      "TTS Service Initialized. Voices found: ${_voices.length}. Selected: $_selectedVoice",
    );
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print("TTS not initialized yet.");
      await _initializeTts(); // Ensure initialization if called early
    }
    if (text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      if (result == 1) {
        print("Speaking: $text");
      } else {
        print("Error speaking: $text");
      }
    }
  }

  Future<void> stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) print("TTS stopped.");
  }

  List<Map<String, String>> getAvailableVoices() => _voices;

  String? getSelectedVoice() => _selectedVoice;

  Future<void> setSelectedVoice(String voiceName) async {
    final voice = _voices.firstWhere(
      (v) => v['name'] == voiceName,
      orElse: () => {'name': '', 'locale': ''},
    );
    if (voice['name']!.isNotEmpty) {
      await _flutterTts.setVoice({
        'name': voice['name']!,
        'locale': voice['locale']!,
      });
      _selectedVoice = voiceName;
      print("TTS Voice set to: $voiceName");
    }
  }

  // Ensure TTS resources are released when no longer needed, e.g., in a dispose method of a widget or app lifecycle.
  void dispose() {
    _flutterTts.stop();
  }
}
