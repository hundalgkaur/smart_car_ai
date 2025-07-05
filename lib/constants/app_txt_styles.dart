import 'package:flutter/material.dart';
import 'package:smart_car_ai_alert/constants/app_colors.dart';

class AppTxtStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 243, 234, 234),
  );
    static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color.fromARGB(255, 239, 235, 245),
  );
    static const TextStyle body = TextStyle(
    fontSize: 14,
    
    color: Color.fromARGB(255, 14, 13, 13),
  );
    static const TextStyle fadedText = TextStyle(
    fontSize: 12,
  
    color: AppColors.greyText,
  );
}