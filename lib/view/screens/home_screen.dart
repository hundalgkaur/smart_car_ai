import 'package:flutter/material.dart';
import 'package:smart_car_ai_alert/constants/app_colors.dart';
import 'package:smart_car_ai_alert/constants/app_icons.dart';
import 'package:smart_car_ai_alert/constants/app_strings.dart';
import 'package:smart_car_ai_alert/view/screens/alert/alert_screen.dart';
import 'package:smart_car_ai_alert/view/screens/audio/audio_screen.dart';
import 'package:smart_car_ai_alert/view/screens/gallery/albumScreen.dart';
import 'package:smart_car_ai_alert/view/widgets/custom_snackbar.dart';
import 'package:smart_car_ai_alert/services/network_services.dart';




class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final NetworkService _networkService = NetworkService();
  Widget _buildButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255,43,149,163),
        foregroundColor: Colors.white,
        minimumSize: const Size(140, 80),
      ),
      icon: Icon(icon),
      label: Text(label, textAlign: TextAlign.center),
      onPressed: onPressed,
    );
  }

  Future<void> _triggerServerAction(
      String endpoint, String successMsg, String failMsg) async {
    setState(() => _isLoading = true);
    final result = await _networkService.triggerAction('/$endpoint');
    setState(() => _isLoading = false);
    if (!context.mounted) return;
    showAppSnackbar(
      context: context,
      message: result ? successMsg : failMsg,
      backgroundColor: result ? AppColors.green : Colors.redAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.labelColor,
        title: const Text(AppStrings.appName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildButton('Record Audio', AppIcons.warningAmber, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AudioRecorderScreen()),
                );
              }),

              _buildButton('Alert History', Icons.history, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AlertScreen()),
  );
}),

              _buildButton('Media', Icons.photo_library, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Albumscreen()),
  );
}),

              _buildButton(_isLoading ? 'Starting...' : 'Monitoring (Start)',
                  AppIcons.camera, () {
                if (!_isLoading) {
                  _triggerServerAction(
                    "/start-monitoring",
                    "Monitoring started",
                    "Failed to start monitoring",
                  );
                }
              }),

              _buildButton(_isLoading ? 'Stopping...' : 'Monitoring (Stop)',
                  AppIcons.stopMonitoring, () {
                if (!_isLoading) {
                  _triggerServerAction(
                    "/stop-monitoring",
                    "Monitoring stopped",
                    "Failed to stop monitoring",
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}