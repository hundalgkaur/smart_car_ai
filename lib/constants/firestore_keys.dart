

class FirestoreKeys {
  // Collection name
  static const String collectionMedia = 'motion_events1';

  // Media-related fields
  static const String fieldType = 'type'; // 'image', 'video', etc.
  static const String fieldUrl = 'url'; // Main URL used for display
  static const String fieldImageUrl = 'image_url'; // Google Drive URL
  static const String fieldImageName = 'image_name';
  static const String fieldVideoName = 'video_name';
  static const String fieldVideoUrl = 'video_url';
  static const String fieldFileType = 'file_type'; // Duplicate of 'type'?

  // Timestamps
  static const String fieldTimestamp = 'timestamp'; // ISO string
  static const String fieldMotionDetectedAt = 'motion_detected_at'; // Optional alt time

  // State/Flags
  static const String isLiked = 'isLiked';
  static const String isDetected = 'isDetected'; // Used in queries (must be added to documents)
  static const String isDeleted = 'isDeleted';
   static const String publicId =  "public_id";


  // Email-related (in case you use them in logic)
  static const String emailReceiver = 'email_receiver';
  static const String emailSent = 'email_sent';

  // Optional final output field
  static const String finalOutput = 'final_output';
}
