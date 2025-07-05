
import 'package:smart_car_ai_alert/model/alert_model.dart';

abstract class AlertState {}
class AlertInitial extends AlertState{}
class AlertLoading extends AlertState{}
class AlertLoaded extends AlertState{
  final List<AlertModel> alerts;
  AlertLoaded(this.alerts);
}
class AlertError extends AlertState {
  final String message;
  AlertError(this.message);
}