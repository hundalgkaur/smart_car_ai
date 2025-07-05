class AlertModel {
  final String? imageUrl;
  final String? videoUrl;
  final String? timestamp;

  final String? publicId;
  final String? documentId;
  AlertModel({
    this.imageUrl,
     this.videoUrl,
      required this.timestamp,
    
        this.publicId,
         required this.documentId,

  });
  factory AlertModel.fromJson(Map<String,dynamic> json, String docId)
  {
     return AlertModel(imageUrl: json['image_url'] as String?, 
     videoUrl: json['final_output'] as String?, 
     timestamp: json['timestamp'] as String?, 
    
      publicId: json['public_id'] as String?,
       documentId: docId
       );
  }

}
