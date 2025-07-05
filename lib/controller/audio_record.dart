// lib/controller/audio_record.dart
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderController {
  final Record _recorder = Record();
  late String _path;

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();

    if (hasPermission) {
      final dir = await getApplicationDocumentsDirectory();
      _path = '${dir.path}/audio.m4a'; // Fixed: using class-level variable

      await _recorder.start(
        path: _path,
        encoder: AudioEncoder.AAC,
        bitRate: 128000,
        samplingRate: 44100,
      );
    } else {
      throw Exception('Microphone permission not granted');
    }
  }

  Future<String> stopRecording() async {
    await _recorder.stop();
    print('Recording saved at: $_path');
    return _path; // Return the correct file path
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  void dispose() {
    _recorder.dispose();
  }
}
