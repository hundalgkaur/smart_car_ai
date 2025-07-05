import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smart_car_ai_alert/constants/firestore_keys.dart';
import 'package:smart_car_ai_alert/view/widgets/media_tile.dart';

// ... all your imports stay the same ...

class VideoAlbumTab extends StatefulWidget {
  const VideoAlbumTab({super.key});

  @override
  State<VideoAlbumTab> createState() => _VideoAlbumTabState();
}

class _VideoAlbumTabState extends State<VideoAlbumTab> {
  final int _limit = 10;
  final List<DocumentSnapshot> _videos = [];
  final Set<String> _selectedDocIds = {};
  final ScrollController _scrollController = ScrollController();

  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      _fetchVideos();
    }
  }

  Future<void> _fetchVideos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection(FirestoreKeys.collectionMedia)
        .where(FirestoreKeys.isDetected, isEqualTo: false)
        .where(FirestoreKeys.fieldType, isEqualTo: 'video')
        .orderBy(FirestoreKeys.fieldTimestamp, descending: true)
        .limit(_limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _lastDoc = snapshot.docs.last;
        _videos.addAll(snapshot.docs);
      });
    } else {
      setState(() => _hasMore = false);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _toggleLike(String docId, bool currentState) async {
    await FirebaseFirestore.instance
        .collection(FirestoreKeys.collectionMedia)
        .doc(docId)
        .update({FirestoreKeys.isLiked: !currentState});

    final index = _videos.indexWhere((doc) => doc.id == docId);
    if (index != -1) {
      final data = Map<String, dynamic>.from(
          _videos[index].data() as Map<String, dynamic>);
      data[FirestoreKeys.isLiked] = !currentState;
      setState(() {
        _videos[index] = _videos[index];
      });
    }
  }

  void _toggleSelection(String docId) {
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

  String _extractUrl(Map<String, dynamic> media) {
    for (final key in ['video_url', 'final_output', 'url']) {
      final value = media[key];
      if (value is String && value.endsWith('.mp4')) {
        return value;
      }
    }
    return '';
  }

  String? _extractPublicId(Map<String, dynamic> data) {
    for (final key in ['video_url', 'url', 'final_output']) {
      final nested = data[key];
      if (nested is Map && nested['public_id'] is String) {
        return nested['public_id'];
      }
    }
    if (data['public_id'] is String) return data['public_id'];
    return null;
  }

  Future<void> _deleteSelectedVideos() async {
    final List<String> deletedIds = [];

    for (final docId in _selectedDocIds) {
      try {
        final doc = _videos.firstWhere((d) => d.id == docId);
        final data = doc.data() as Map<String, dynamic>;
        final publicId = _extractPublicId(data);
        final fileType = data['file_type'];

        if (publicId != null && fileType is String) {
          final success = await _deleteSingleMedia(publicId, fileType, docId: docId);
          if (success) deletedIds.add(docId);
        }
      } catch (e) {
        print(' Exception deleting $docId: $e');
      }
    }

    setState(() {
      _videos.removeWhere((doc) => deletedIds.contains(doc.id));
      _selectedDocIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<bool> _deleteSingleMedia(String publicId, String fileType, {String? docId}) async {
    final uri = Uri.parse('http://smartcarai.duckdns.org:5000/delete_media');


    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'public_id': publicId,
          'file_type': fileType,
          if (docId != null) 'document_id': docId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print(' Error connecting to Flask: $e');
    }

    return false;
  }

  String _formatTimestamp(dynamic timestamp) {
    DateTime? parsedTime;
    if (timestamp is Timestamp) {
      parsedTime = timestamp.toDate();
    } else if (timestamp is String) {
      parsedTime = DateTime.tryParse(timestamp);
    }
    return parsedTime != null
        ? DateFormat('yyyy-MM-dd – hh:mm a').format(parsedTime)
        : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isSelectionMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSelectedVideos,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedDocIds.clear();
                    });
                  },
                ),
                const Spacer(),
                Text(
                  '${_selectedDocIds.length} selected',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              _videos.isEmpty && !_isLoading
                  ? const Center(child: Text('No videos found'))
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _videos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final doc = _videos[index];
                        final media = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;
                        final isSelected = _selectedDocIds.contains(docId);
                        final url = _extractUrl(media);

                        return MediaTile(
                          mediaType:
                              media[FirestoreKeys.fieldType] ?? 'video',
                          url: url,
                          time: _formatTimestamp(
                              media[FirestoreKeys.fieldTimestamp]),
                          isLiked: media[FirestoreKeys.isLiked] ?? false,
                          docId: docId,
                          isSelected: isSelected,
                          onLikeToggle: () => _toggleLike(
                              docId, media[FirestoreKeys.isLiked] ?? false),
                          onLongPress: () => _toggleSelection(docId),
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelection(docId);
                            }
                          },
                        );
                      },
                    ),
              if (_isLoading)
                const Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
