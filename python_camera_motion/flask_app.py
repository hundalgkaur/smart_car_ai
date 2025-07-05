import os
import platform
import subprocess
import cv2
import sys
from flask import Flask, jsonify, request
from flask_cors import CORS
from threading import Thread, Event
from firebase_admin import firestore
import cloudinary
import cloudinary.uploader
from cloudinary_service.cloudinary_uploader import delete_single_file
from datetime import datetime
import logging
import sys
print(" Using Python:", sys.executable)
print(" sys.path:", sys.path)
# Logging
logging.basicConfig(level=logging.DEBUG)

# Add root directory to sys.path
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(root_dir)
print(" Root directory added to sys.path:", root_dir)

# Import your modules
from python_camera_motion.handle_motion import handle_motion
import python_camera_motion.monitoring_state as state
from upload.upload_final_merged_video import upload_video_to_drive
from upload.upload_image import upload_to_drive
from alerts.send_email import send_alert_email
from firebase_services.store_media_to_firestore import add_media_to_firestore

# Initialize Flask app
app = Flask(__name__)
CORS(app)
print(" Flask app initialized with CORS")

# Firestore DB instance
db = firestore.client()

# Monitoring control
state.monitoring_active = False
monitoring_thread_event = Event()

@app.route('/start-monitoring')
def start_monitoring():
   
    if state.monitoring_active:
        return ' Monitoring is already running!', 409

    print(" Starting monitoring...", flush=True)
    monitoring_thread_event.clear()
    state.monitoring_active = True

    def run_motion_detection():
        camera = cv2.VideoCapture(0)
        while state.monitoring_active and not monitoring_thread_event.is_set():
            handle_motion(camera, monitoring_thread_event)
            cv2.waitKey(1000)
        camera.release()
        print(" Monitoring thread exited.")

    Thread(target=run_motion_detection).start()
    return ' Monitoring started in background!', 200

@app.route('/stop-monitoring')
def stop_monitoring():
    if not state.monitoring_active:
        return ' Monitoring is already stopped!', 409

    state.monitoring_active = False
    monitoring_thread_event.set()
    print(" Stopping monitoring...")

    try:
        motion_detected_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        email_receiver = "gkhundal00001@gmail.com"
        email_sent = False

        image_name = image_url = video_name = video_url = None
        audio_name = "audio/audio_2025-04-22-12-11-43.wav"

        if hasattr(state, "last_image_path"):
            image_name, image_url = upload_to_drive(state.last_image_path)
            print(f" Image uploaded: {image_url}")
        else:
            print(" No image found.")

        if hasattr(state, "last_video_path"):
            video_name, video_url = upload_video_to_drive(state.last_video_path)
            print(f" Video uploaded: {video_url}")
        else:
            print(" No video found.")

        if state.last_image_path and state.last_video_path:
            send_alert_email(state.last_image_path, state.last_video_path)
            email_sent = True
            print(" Alert email sent.")

        add_media_to_firestore(
            image_path=state.last_image_path if hasattr(state, "last_image_path") else None,
            video_path=state.last_video_path if hasattr(state, "last_video_path") else None,
            audio_path=audio_name,
            motion_detected_at=motion_detected_at,
            email_receiver=email_receiver,
            email_sent=email_sent
        )
        print(" Firestore entry created.")

    except Exception as e:
        print(f" Error during post-monitoring process: {e}")

    return ' Monitoring stopped successfully!', 200

import re

# Function to extract public_id from a Cloudinary URL
def extract_public_id_from_url(url):
    # Regex to capture the public_id from Cloudinary URL
    match = re.search(r'\/v\d+\/([a-zA-Z0-9_-]+)\.mp4$', url)
    if match:
        return match.group(1)
    return None

@app.route('/delete_media', methods=['POST'])
def delete_media():
    print(" Received delete_media request")

    try:
        data = request.get_json()
        public_id = data.get("public_id")
        file_type = data.get("file_type")
        document_id = data.get("document_id")  # Optional

        print(" public_id:", public_id)
        print(" file_type:", file_type)
        print(" document_id:", document_id)

        if not public_id or not file_type:
            return jsonify({"error": "Missing public_id or file_type"}), 400

        doc_id = None

        if document_id:
            #  Direct fetch
            doc = db.collection("motion_events1").document(document_id).get()
            if doc.exists:
                doc_id = doc.id
            else:
                print(" Provided document ID does not exist")
                return jsonify({"error": "Document with provided ID not found"}), 404
        else:
            # 🔍 Query by top-level public_id and file_type
            query = db.collection("motion_events1") \
                      .where("file_type", "==", file_type) \
                      .where("public_id", "==", public_id) \
                      .stream()

            for doc in query:
                doc_id = doc.id
                break

            if not doc_id:
                print(" No matching document found")
                return jsonify({"error": "No matching Firestore document found"}), 404

        #  Delete document from Firestore
        db.collection("motion_events1").document(doc_id).delete()
        print(f" Deleted Firestore doc: {doc_id}")

        # 🗑 Delete local file
        extensions = {"image": ".jpg", "video": ".mp4", "audio": ".wav"}
        folders = {"image": "images", "video": "videos", "audio": "audio"}
        if file_type in extensions:
            local_path = os.path.join(folders[file_type], public_id + extensions[file_type])
            if os.path.exists(local_path):
                os.remove(local_path)
                print(f"🗑 Deleted local file: {local_path}")
            else:
                print("⚠ Local file not found")

        #  Delete from Cloudinary
        result = delete_single_file(public_id, file_type)
        if result.get("result") == "ok":
            print(" Cloudinary delete success")
            return jsonify({"message": "Deleted successfully"}), 200
        else:
            print("Cloudinary delete failed")
            return jsonify({
                "message": "Firestore and local deleted, Cloudinary failed",
                "cloudinary_result": result
            }), 206

    except Exception as e:
        print(f" Exception in delete_media: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/open-media')
def open_media():
    try:
        # Replace 'media' with your actual folder like 'images' or 'videos' if needed
        folder_path = os.path.abspath("media")  

        if platform.system() == "Windows":
            os.startfile(folder_path)
        elif platform.system() == "Darwin":  # macOS
            subprocess.Popen(["open", folder_path])
        else:  # Linux
            subprocess.Popen(["xdg-open", folder_path])

        print(" Media folder opened.")
        return jsonify({"message": "Media folder opened"}), 200
    except Exception as e:
        print(f" Error opening media: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/open-alert-history')
def open_alert_history():
    try:
        # Replace this with your actual path to alert log
        alert_file = os.path.abspath("alert_logs/alerts.txt")

        if platform.system() == "Windows":
            os.startfile(alert_file)
        elif platform.system() == "Darwin":
            subprocess.Popen(["open", alert_file])
        else:
            subprocess.Popen(["xdg-open", alert_file])

        print(" Alert history opened.")
        return jsonify({"message": "Alert history opened"}), 200
    except Exception as e:
        print(f" Error opening alert history: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=5000, debug=True)