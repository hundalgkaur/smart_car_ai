import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewUploadedImagesScreen extends StatefulWidget {
  const ViewUploadedImagesScreen({super.key});

  @override
  State<ViewUploadedImagesScreen> createState() => _ViewUploadedImagesScreenState();
}

class _ViewUploadedImagesScreenState extends State<ViewUploadedImagesScreen> {
  final List<DocumentSnapshot> _documents = [];
  final Set<String> _selectedDocIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('motion_events1')
          .where('type', isEqualTo: 'image')
          .orderBy('timestamp', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _documents.clear();
          _documents.addAll(querySnapshot.docs);
        });
      }
    } catch (e) {
      print(' Error fetching images: $e');
    }
  }

  void _toggleSelection(String docId) {
    if (mounted) {
      setState(() {
        if (_selectedDocIds.contains(docId)) {
          _selectedDocIds.remove(docId);
          if (_selectedDocIds.isEmpty) _isSelectionMode = false;
        } else {
          _selectedDocIds.add(docId);
          _isSelectionMode = true;
        }
      });
    }
  }

  String _extractImageUrl(Map<String, dynamic> data) {
    final urlField = data['image_url'];
    if (urlField is String && urlField.isNotEmpty) return urlField;
    return '';
  }

  Future<void> _deleteSelectedImages() async {
    for (final docId in _selectedDocIds) {
      final doc = _documents.firstWhere((d) => d.id == docId);
      final data = doc.data() as Map<String, dynamic>;
      final publicId = data['public_id'];
      final fileType = data['file_type'];

      if (publicId is String && fileType is String) {
        final success = await _deleteSingleMedia(publicId, fileType);
        if (success) {
          print(' Deleted: $docId');
        } else {
          print(' Failed to delete: $docId');
        }
      }
    }

    if (mounted) {
      setState(() {
        _documents.removeWhere((doc) => _selectedDocIds.contains(doc.id));
        _selectedDocIds.clear();
        _isSelectionMode = false;
      });
    }
  }

  Future<bool> _deleteSingleMedia(String publicId, String fileType) async {
    final uri = Uri.parse('http://smartcarai.duckdns.org:5000/delete_media');


    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'public_id': publicId,
          'file_type': fileType,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print(' Error connecting to Flask: $e');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //  Show delete/cancel buttons inside content
        if (_isSelectionMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSelectedImages,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _isSelectionMode = false;
                        _selectedDocIds.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _documents.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemBuilder: (context, index) {
              final doc = _documents[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final isSelected = _selectedDocIds.contains(docId);
              final imageUrl = _extractImageUrl(data);

              return GestureDetector(
                onLongPress: () => _toggleSelection(docId),
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(docId);
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      ),
                    );
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image));
                      },
                    ),
                    if (_isSelectionMode)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.green : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
