
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car_ai_alert/bloc/media_bloc/alert_event%20.dart';
import 'package:smart_car_ai_alert/bloc/media_bloc/alert_state.dart';
import 'package:smart_car_ai_alert/model/alert_model.dart';




class AlertBloc extends Bloc<AlertEvent, AlertState> {
  AlertBloc() : super(AlertInitial()) {
    on<FetchAlertEvent>(_onFetchAlerts);
  }

  Future<void> _onFetchAlerts(FetchAlertEvent event, Emitter<AlertState> emit) async {
    emit(AlertLoading());
    try {
      final snapshot = await FirebaseFirestore.instance.collection('motion_events1').get();
      final alerts = snapshot.docs.map((doc) => AlertModel.fromJson(doc.data(), doc.id)).toList();
      emit(AlertLoaded(alerts));
    } catch (e) {
      emit(AlertError('Failed to fetch alerts: ${e.toString()}'));
    }
  }
}