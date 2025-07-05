import 'package:flutter/material.dart';
import 'package:smart_car_ai_alert/constants/app_colors.dart';

void showAppSnackbar({
  required BuildContext context,
  required String message,
  Color backgroundColor = AppColors.black87,
  Duration duration = const Duration(seconds: 2),

}){
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,)
       );
}