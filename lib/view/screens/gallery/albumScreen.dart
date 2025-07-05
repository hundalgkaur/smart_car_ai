import 'package:flutter/material.dart';
import 'package:smart_car_ai_alert/constants/app_colors.dart';
import 'package:smart_car_ai_alert/view/screens/gallery/image_album_tab.dart';
import 'package:smart_car_ai_alert/view/screens/gallery/video_album_tab.dart';

class Albumscreen extends StatelessWidget {
  const Albumscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: AppColors.labelColor,
          title: const Text('Albums'),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.greyText,
            indicatorColor: AppColors.orange,
            tabs: [
              Tab(text: 'Images'),
              Tab(text: 'Videos'),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Positioned.fill(
            //   child: Image.asset(
            //     'images/background2.jpg',
            //     fit: BoxFit.cover,
            //   ),
            // ),
            const TabBarView(
              children: [
                ViewUploadedImagesScreen(),
                VideoAlbumTab(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
