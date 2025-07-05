from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore as admin_firestore
import sys
import os
sys.path.append(os.path.abspath(os.path.dirname(__file__)))

from cloudinary_service.cloudinary_uploader import upload_file_to_cloudinary

# Initialize Firebase
if not firebase_admin._apps:
    cred = credentials.Certificate("firebase_credentials.json")
    firebase_admin.initialize_app(cred)

db = admin_firestore.client()

def add_media_to_firestore(
    image_path=None, video_path=None, audio_path=None,
    motion_detected_at=None, email_receiver=None, email_sent=None
):
    try:
        now = datetime.now()
        timestamp = now.isoformat()
        formatted_time = now.strftime("%Y-%m-%d_%H-%M-%S")
        collection_name = "motion_events1"

        # Upload to Cloudinary
        image_result = upload_file_to_cloudinary(image_path) if image_path else None
        video_result = upload_file_to_cloudinary(video_path) if video_path else None
        audio_result = upload_file_to_cloudinary(audio_path) if audio_path else None

        # Save image metadata
        if image_result:
            db.collection(collection_name).add({
                "type": "image",
                "file_type": "image",
                "image_name": os.path.basename(image_path),
                "image_url": image_result.get("url"),
                "public_id": image_result.get("public_id"),
                "timestamp": timestamp,
                "motion_detected_at": motion_detected_at,
                "email_receiver": email_receiver,
                "email_sent": email_sent,
                "isLiked": False,
                "isDeleted": False,
                "isDetected": False
            })
            print("Image metadata added to Firestore")

        # Save video metadata
        if video_result:
            db.collection(collection_name).add({
                "type": "video",
                "file_type": "video",
                "video_name": os.path.basename(video_path),
                "video_url": video_result.get("url"),
                "public_id": video_result.get("public_id"),
                "final_output": video_result.get("url"),
                "timestamp": timestamp,
                "motion_detected_at": motion_detected_at,
                "email_receiver": email_receiver,
                "email_sent": email_sent,
                "isLiked": False,
                "isDeleted": False,
                "isDetected": False
            })
            print(" Video metadata added to Firestore")

        # Save audio metadata
        if audio_result:
            db.collection(collection_name).add({
                "type": "audio",
                "file_type": "audio",
                "audio_name": os.path.basename(audio_path),
                "audio_url": audio_result.get("url"),
                "public_id": audio_result.get("public_id"),
                "timestamp": timestamp,
                "motion_detected_at": motion_detected_at,
                "email_receiver": email_receiver,
                "email_sent": email_sent,
                "isLiked": False,
                "isDeleted": False,
                "isDetected": False
            })
            print("Audio metadata added to Firestore")

    except Exception as e:
        print(f" Firestore error: {e}")
