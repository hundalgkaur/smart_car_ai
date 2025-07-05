import 'package:flutter/material.dart';
import 'package:smart_car_ai_alert/constants/app_icons.dart';
import 'package:smart_car_ai_alert/constants/app_colors.dart';
import 'package:smart_car_ai_alert/constants/app_strings.dart';
import 'package:smart_car_ai_alert/constants/app_txt_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to HomeScreen after a delay of 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });

    return Scaffold(
      backgroundColor:AppColors.labelColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.carCrash,
              size: 100,
              color: AppColors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.appName,
              style: AppTxtStyles.heading,
            ),
            const SizedBox(height: 10),
            const Text(
              AppStrings.welcome,
              style: AppTxtStyles.subheading,
            ),
          ],
        ),
      ),
    );
  }
}
