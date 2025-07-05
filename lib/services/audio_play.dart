import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlaybackService {
  final AudioPlayer _player = AudioPlayer();

  void listenForNewAudio() {
    FirebaseFirestore.instance
        .collection('voice_commands')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final url = snapshot.docs.first.data()['url'];
        if (url != null) {
          print("Playing audio from Firestore URL: $url");
          _player.play(UrlSource(url));
        }
      }
    });
  }
}
