import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = 'http://smartcarai.duckdns.org:5000';
//  Localhost instead of IP

  static Future<bool> startMonitoring() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/start-monitoring'))
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        print("Success: Monitoring started");
        return true;
      } else {
        print("Failed to start monitoring, status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('Error during start monitoring: $e');
      return false;
    }
  }

  static Future<bool> stopMonitoring() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/stop-monitoring'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("Success: Monitoring stopped");
        return true;
      } else {
        print("Failed to stop monitoring, status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('Error during stop monitoring: $e');
      return false;
    }
  }

  static Future<bool> deleteMedia(String publicId, String fileType) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/delete_media'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'public_id': publicId,
              'file_type': fileType,
            }),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        print("Success: Media deleted");
        return true;
      } else {
        print("Failed to delete media, status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('Error during delete media: $e');
      return false;
    }
  }
}
