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

def add_audio_to_recordings(
    audio_path=None, motion_detected_at=None, email_receiver=None, email_sent=None
):
    try:
        now = datetime.now()
        timestamp = now.isoformat()
        formatted_time = now.strftime("%Y-%m-%d_%H-%M-%S")
        collection_name = "recordings"  # Store audio files in a separate collection

        # Upload to Cloudinary
        audio_result = upload_file_to_cloudinary(audio_path) if audio_path else None

        # Save audio metadata in the "recordings" collection
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
            print("Audio metadata added to Firestore (recordings)")

    except Exception as e:
        print(f"Firestore error: {e}")
