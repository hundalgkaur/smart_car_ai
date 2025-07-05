import sys
import os 
# Add the root project directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__))))



from alerts.send_email import send_alert_email
from upload.upload_final_merged_video import upload_video_to_drive
from upload.upload_image import upload_to_drive



def handle_motion_alert(image_path, video_path):
    print("handle alert:")
    # If you still want to upload too
    upload_to_drive(image_path)
    upload_video_to_drive(video_path)

    print(f"📷 Image path: {image_path}")
    print(f"🎥 Video path: {video_path}")

    # Send email with attachments
    send_alert_email(image_path, video_path)
