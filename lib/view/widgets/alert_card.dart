import 'package:flutter/material.dart';
import 'package:smart_car_ai_alert/constants/app_strings.dart';
import 'package:smart_car_ai_alert/model/alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final int index;
  final VoidCallback onDelete;

  const AlertCard({
    super.key,
    required this.alert,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        index.isEven ? const Color.fromARGB(255, 137, 204, 212) : const Color.fromARGB(255, 208, 236, 214);

    final bool isImage = (alert.imageUrl ?? '').isNotEmpty && (alert.videoUrl?.isEmpty ?? true);
    final bool isVideo = (alert.videoUrl ?? '').isNotEmpty && (alert.imageUrl?.isEmpty ?? true);

    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isImage ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isImage ? 'IMAGE ALERT' : 'VIDEO ALERT',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                // Image Preview
              // Image Thumbnail (like video style)
if (isImage)
  GestureDetector(
    onTap: () => _showImageDialog(context, alert.imageUrl ?? ''),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'images/image_placeholder.png', // Your saved image
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const Icon(Icons.image, size: 48, color: Colors.white),
        ],
      ),
    ),
  ),


                // Video Thumbnail
                if (isVideo)
                  GestureDetector(
                    onTap: () => _showVideoDialog(context, alert.videoUrl ?? ''),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'images/video_thumbnail_placeholder.jpg',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                Text(
                  "${AppStrings.emailSentAt} ${alert.timestamp}",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this alert?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('motion_events1')
                  .doc(alert.documentId)
                  .delete();
              Navigator.of(context).pop();
              onDelete(); // Refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Alert deleted successfully")),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showVideoDialog(BuildContext context, String videoUrl) {
    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: FutureBuilder(
            future: controller.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                controller.play();
                return AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                );
              } else {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      },
    ).then((_) {
      controller.pause();
      controller.dispose();
    });
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text("Failed to load image")),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
