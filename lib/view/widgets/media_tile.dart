import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_car_ai_alert/constants/app_colors.dart';
import 'package:smart_car_ai_alert/constants/app_icons.dart';
import 'package:smart_car_ai_alert/view/widgets/videoPlayerWidget.dart';

class MediaTile extends StatelessWidget {
  final String mediaType;
  final String url;
  final String time;
  final bool isLiked;
  final bool isSelected;
  final String docId;
  final VoidCallback onLikeToggle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MediaTile({
    super.key,
    required this.mediaType,
    required this.url,
    required this.time,
    required this.isLiked,
    required this.docId,
    required this.onLikeToggle,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = 'Unknown Time';
    try {
      final parsedTime = DateTime.tryParse(time);
      if (parsedTime != null) {
        formattedTime = DateFormat('dd MMM, hh:mma').format(parsedTime);
      }
    } catch (_) {}

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: mediaType == 'image'
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image));
                        },
                      )
                    : VideoPlayerWidget(videoUrl: url),
              ),

              if (isSelected)
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),

              Positioned(
                top: 6,
                right: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? AppIcons.like : AppIcons.favoriteBorder,
                        color: AppColors.likepink,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onLikeToggle,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isSelected)
                Positioned(
                  top: 6,
                  left: 6,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
