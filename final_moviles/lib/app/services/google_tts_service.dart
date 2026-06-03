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
  bool _playing = false;

  static const _url =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  static const _voice = {
    'languageCode': 'es-ES',
    'name': 'es-ES-Chirp3-HD-Aoede', 
  };

  Future<void> speak(String texto) async {
    if (texto.isEmpty) return;
    await stop();

    try {
      final audioBytes = await _synthesize(texto);
      if (audioBytes == null) return;

      final file = await _guardarTemporal(audioBytes);
      await _reproducir(file);
    } catch (e) {
      debugPrint('❌ GoogleTtsService.speak error: $e');
    }
  }

  Future<void> stop() async {
    if (_playing) {
      await _player.stop();
      _playing = false;
    }
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
          'speakingRate': 1.0, 
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
    _playing = true;
    await _player.setFilePath(file.path);
    await _player.play();
    _playing = false;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}