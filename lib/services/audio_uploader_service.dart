
import 'package:http/http.dart' as http;
import '../constants/app_server_config.dart';

Future<void> uploadAudioFile(String filePath) async {
  var uri = Uri.parse('http://${AppServerConfig.receiverIP}:${AppServerConfig.receiverPort}/upload');
  var request = http.MultipartRequest('POST', uri);

  request.files.add(await http.MultipartFile.fromPath('audio', filePath));
  var response = await request.send();

  if (response.statusCode == 200) {
    print(' Audio sent to laptop successfully');
  } else {
    throw Exception(' Failed to send audio: ${response.statusCode}');
  }
}
