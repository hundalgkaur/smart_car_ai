import 'package:flutter/material.dart';
import 'package:smart_car_ai_alert/constants/app_colors.dart';
import 'package:smart_car_ai_alert/constants/app_strings.dart';
import 'package:smart_car_ai_alert/view/screens/gallery/albumScreen.dart';
import 'package:smart_car_ai_alert/view/screens/gallery/photoes_screen.dart';

class GalleryHome extends StatelessWidget{
  const GalleryHome({super.key});
  @override 
  Widget build(BuildContext context)
  {
    return DefaultTabController(length: 2, child: Scaffold(
      backgroundColor: AppColors.background,
      appBar:AppBar(
        title: const Text("Gallery"),
        bottom: const TabBar(
          indicatorColor: AppColors.deepPurple,
          tabs: [
            Tab(text: AppStrings.photos),
            Tab(text: AppStrings.albums)
          ])),
          body:  TabBarView(children: [
             // Background image
            Positioned.fill(
              child: Image.asset(
                'images/background2.jpg',
                fit: BoxFit.cover,
              ),
            ),
            PhotosScreen(),
            Albumscreen(),]
      
    )));
  }
}