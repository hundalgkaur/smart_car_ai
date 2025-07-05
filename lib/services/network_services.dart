import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_car_ai_alert/constants/app_server_config.dart';

class NetworkService {
 final String baseUrl ='http://${AppServerConfig.receiverIP}:${AppServerConfig.receiverPort}';


  Future<bool> triggerAction(String endpoint) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl$endpoint')); // <-- fixed here

    return response.statusCode == 200;
  } catch (e) {
    print('Error hitting $endpoint: $e');
    return false;
  }
}


  /// Start monitoring
  Future<String> startMonitoring() async {
    final response = await http.get(Uri.parse('$baseUrl/start-monitoring'));
    return response.body;
  }

  /// Stop monitoring
  Future<String> stopMonitoring() async {
    final response = await http.get(Uri.parse('$baseUrl/stop-monitoring'));
    return response.body;
  }

  /// Delete media (image or video)
  Future<Map<String, dynamic>> deleteMedia({
    required String publicId,
    required String fileType,
    String? documentId, // Optional
  }) async {
    final uri = Uri.parse('$baseUrl/delete_media');
    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "public_id": publicId,
          "file_type": fileType,
          if (documentId != null) "document_id": documentId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 206) {
        return jsonDecode(response.body);
      } else {
        print(' Failed to delete. Status: ${response.statusCode}');
        print(' Body: ${response.body}');
        return {
          "error": "Failed to delete",
          "status": response.statusCode,
          "body": response.body
        };
      }
    } catch (e) {
      print(" Exception in deleteMedia: $e");
      return {"error": e.toString()};
    }
  }
}
