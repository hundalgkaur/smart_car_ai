import sys
import os
import threading
import time
import cv2

# Get root directory path
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
print(" Adding to sys.path:", root_dir)
sys.path.append(root_dir)

# Import modules
from Controller.handleMotion import handle_motion_alert
from audio_recorder import record_audio_if_human as record_audio
from motion_detector import record_video_if_human as record_video
from image_capture import capture_image_if_human as capture_image
from merge_audio_video import merge_audio_and_video
from upload.upload_image import upload_to_drive
from upload.upload_final_merged_video import upload_video_to_drive
from FirebaseLogger import log_alert_data
from constants import (
    generate_audio_filename,
    generate_video_filename,
    generate_final_output_filename,
)

#  NEW: Human detection import
from detect.human_detector import is_human_detected


def main():
    print(" Starting main program...")

    stop_event = threading.Event()
    duration = 30  # seconds
    start_time = time.time()

    print(" Initializing camera...")
    camera = cv2.VideoCapture(0)
    if not camera.isOpened():
        print(" Camera could not be opened.")
        return
    print(" Camera successfully opened.")

    #  Check for human presence before continuing
    print(" Checking for human presence before capturing...")
    detected = False
    for _ in range(15):  # Try for ~15 seconds
        ret, frame = camera.read()
        if not ret:
            continue
        if is_human_detected(frame):
            detected = True
            print(" Human detected!")
            break
        print(" No human detected, retrying...")
        cv2.waitKey(1000)  # Wait 1 second between tries

    if not detected:
        print(" No human detected. Skipping recording.")
        camera.release()
        cv2.destroyAllWindows()
        return

    # Proceed to capture image
    image_path = capture_image(stop_event, camera)
    if not image_path:
        print(" Failed to capture image.")
        return

    # Generate file paths
    video_filename = generate_video_filename()
    audio_filename = generate_audio_filename()
    output_filename = generate_final_output_filename()

    print(" File paths generated.")
    print(f"Video: {video_filename}")
    print(f"Audio: {audio_filename}")
    print(f"Output: {output_filename}")

    # Start threads
    print(" Starting recording threads...")
    video_thread = threading.Thread(target=record_video, args=(stop_event, camera, duration, video_filename))
    audio_thread = threading.Thread(target=record_audio, args=(stop_event, camera, audio_filename, duration))


    video_thread.start()
    audio_thread.start()

    # Wait for duration
    while time.time() - start_time < duration:
        time.sleep(1)

    # Stop and join
    stop_event.set()
    video_thread.join()
    audio_thread.join()

    # Cleanup
    camera.release()
    cv2.destroyAllWindows()
    print(" Recording complete. Now merging audio and video...")

    if not os.path.exists(video_filename):
        print(f" Video file not found: {video_filename}")
        return
    if not os.path.exists(audio_filename):
        print(f" Audio file not found: {audio_filename}")
        return

    merge_audio_and_video(video_filename, audio_filename, output_filename)
    print(f" Merged file saved as: {output_filename}")
    print(f" Image path: {image_path}")
    print(f" Video path: {output_filename}")

    # Send motion alert
    print(handle_motion_alert(image_path, output_filename))

    # Log to Firebase
    log_alert_data(
        image_name=upload_to_drive(image_path),
        final_output=upload_video_to_drive(output_filename),
        email_sent=True
    )


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f" An error occurred: {e}")
