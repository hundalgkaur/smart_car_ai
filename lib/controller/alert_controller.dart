import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_car_ai_alert/model/alert_model.dart';

class AlertService {
  static Future<List<AlertModel>> fetchAlerts() async {
    final snapshot = await
    FirebaseFirestore.instance.collection('motion_events1').get();
    return snapshot.docs.map((doc)=> AlertModel.fromJson(doc.data(), doc.id)).toList();
  }
}