import 'package:flutter/material.dart';
import 'package:smart_car_ai_alert/constants/app_colors.dart';
import 'package:smart_car_ai_alert/model/alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_car_ai_alert/view/widgets/alert_card.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  late Future<List<AlertModel>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = fetchAlerts();
  }

  Future<List<AlertModel>> fetchAlerts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('motion_events1').get();
    return snapshot.docs
        .map((doc) => AlertModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  void refreshAlerts() {
    setState(() {
      _alertsFuture = fetchAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  backgroundColor: AppColors.labelColor,
          title: const Text('User Alerts', style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),),),
      body: FutureBuilder<List<AlertModel>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No alerts found.'));
          }

          final alerts = snapshot.data!;
          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return AlertCard(
                alert: alerts[index],
                index: index,
                onDelete: refreshAlerts,
              );
            },
          );
        },
      ),
    );
  }
}