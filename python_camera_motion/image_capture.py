from threading import Thread, Lock
import cv2
import time
from python_camera_motion.constants import generate_image_filename
from python_camera_motion.detect.human_detector import is_human_detected
from upload.upload_image import upload_to_drive

# Optional: shared camera lock (declare this globally or pass it in)
camera_lock = Lock()

def capture_image_if_human(stop_event, camera):
    print(" Attempting to capture image after confirmed human detection...")

    time.sleep(0.5)  # Give camera and threads time to stabilize after detection

    attempts = 0
    while not stop_event.is_set() and attempts < 40:
        with camera_lock:
            ret, frame = camera.read()
        
        if not ret:
            print(" Failed to capture frame.")
            attempts += 1
            time.sleep(1)
            continue

        # Resize frame for consistency with video recording and detector
        frame_resized = cv2.resize(frame, (640, 480))

        if is_human_detected(frame_resized):
            filename = generate_image_filename()
            cv2.imwrite(filename, frame_resized)

         

            print(f" Image captured and saved: {filename}")
            return filename
        else:
            print(" No human detected in frame, retrying...")
            attempts += 1
            time.sleep(1)  # Wait 1 second before trying again

    print(" Max attempts reached or stop event triggered. No human detected.")
    return None
