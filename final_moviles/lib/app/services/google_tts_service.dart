import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class GoogleTtsService {
  GoogleTtsService._();
  static final GoogleTtsService instance = GoogleTtsService._();

  final _player = AudioPlayer();
  // Token incremented on every speak() call. Each in-flight call checks its own
  // token before each async step and aborts if a newer call has taken over.
  int _token = 0;

  Stream<bool> get playingStream => _player.playingStream;

  static const _url =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  static const _voice = {
    'languageCode': 'es-ES',
    'name': 'es-ES-Chirp3-HD-Aoede',
  };

  Future<void> speak(String texto) async {
    if (texto.isEmpty) return;
    final myToken = ++_token;

    await _player.stop();
    if (myToken != _token) return;

    try {
      final audioBytes = await _synthesize(texto);
      if (myToken != _token) return; // superseded during synthesis

      if (audioBytes == null) return;
      final file = await _guardarTemporal(audioBytes);
      if (myToken != _token) return; // superseded during file write

      await _reproducir(file);
    } catch (e) {
      debugPrint('GoogleTtsService.speak error: $e');
    }
  }

  Future<void> stop() async {
    ++_token; // cancel any in-flight speak()
    await _player.stop();
  }

  Future<Uint8List?> _synthesize(String texto) async {
    final apiKey = dotenv.env['GOOGLE_TTS_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('❌ GOOGLE_TTS_KEY no encontrada en .env');
      return null;
    }

    final response = await http.post(
      Uri.parse('$_url?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'input': {'text': texto},
        'voice': _voice,
        'audioConfig': {
          'audioEncoding': 'MP3',
          'speakingRate': 0.9,  
          'pitch': 0.0,        
          'volumeGainDb': 2.0,  
          'effectsProfileId': ['handset-class-device'], 
        },
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('❌ Google TTS API error ${response.statusCode}: ${response.body}');
      return null;
    }

    final json = jsonDecode(response.body);
    final audioContent = json['audioContent'] as String;
    return base64Decode(audioContent);
  }

  Future<File> _guardarTemporal(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tts_output.mp3');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _reproducir(File file) async {
    await _player.setFilePath(file.path);
    await _player.play();
    // play() returns when playback starts, not when it ends.
    // Wait until the player stops (completed or stopped by stop()).
    await _player.playerStateStream.firstWhere(
      (s) =>
          s.processingState == ProcessingState.completed ||
          s.processingState == ProcessingState.idle,
    );
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}