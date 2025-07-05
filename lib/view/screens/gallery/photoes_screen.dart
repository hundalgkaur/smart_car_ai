import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_car_ai_alert/constants/firestore_keys.dart';
import 'package:smart_car_ai_alert/view/widgets/media_tile.dart';

class PhotosScreen extends StatelessWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirestoreKeys.collectionMedia)
          .where(FirestoreKeys.isDetected, isEqualTo: false)
          .where(FirestoreKeys.fieldType, isEqualTo: 'image') // Ensure it's fetching only images
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading photos. Please try again later.'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text('No photos found. Add some to see here.'),
          );
        }

        // Sort by timestamp client-side (in case it's stored as a string)
        docs.sort((a, b) {
          final aTime = DateTime.tryParse((a.data() as Map<String, dynamic>)[FirestoreKeys.fieldTimestamp] ?? '') ?? DateTime(1970);
          final bTime = DateTime.tryParse((b.data() as Map<String, dynamic>)[FirestoreKeys.fieldTimestamp] ?? '') ?? DateTime(1970);
          return bTime.compareTo(aTime); // Sort from newest to oldest
        });

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final media = docs[index].data() as Map<String, dynamic>;

            final rawTime = media[FirestoreKeys.fieldTimestamp] as String? ?? '';
            final parsedTime = DateTime.tryParse(rawTime);
            final formattedTime = parsedTime != null
                ? DateFormat('yyyy-MM-dd – hh:mm a').format(parsedTime)
                : 'Unknown';

            return MediaTile(
              mediaType: media[FirestoreKeys.fieldType] ?? 'image',
              url: media[FirestoreKeys.fieldUrl] ?? '',
              time: formattedTime,
              isLiked: media[FirestoreKeys.isLiked] ?? false,
              docId: docs[index].id,
              onLikeToggle: () {
                // Handle like toggle logic
                // Example: You can update Firestore to toggle the "isLiked" field here.
              },
            );
          },
        );
      },
    );
  }
}
