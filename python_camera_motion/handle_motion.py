import os
import sys
import threading
import cv2
import time

# Set root path
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(root_dir)
print(" sys.path updated with root dir:", root_dir)

from alerts.send_email import send_alert_email
from python_camera_motion.audio_recorder import record_audio
from python_camera_motion.constants import FINAL_OUTPUT_FOLDER, generate_audio_filename
from python_camera_motion.image_capture import capture_image_if_human
from python_camera_motion.merge_audio_video import merge_audio_and_video
from upload.upload_final_merged_video import upload_video_to_drive
from upload.upload_image import upload_to_drive
import python_camera_motion.monitoring_state as state

def handle_motion(camera, stop_event):
    from python_camera_motion.motion_detector import record_video_if_human

    while state.monitoring_active and not stop_event.is_set():
        print(" Human detected - starting parallel capture")

        human_detected_event = threading.Event()
        captured_image_path = [None]
        video_filename = [None]

        def capture_image_task():
            try:
                print("Waiting for human detection by video thread...")
                human_detected_event.wait(timeout=10)
                if not human_detected_event.is_set():
                    print(" No human detected by video. Skipping image capture.")
                    return
                print(" Human confirmed. Capturing image...")
                path = capture_image_if_human(stop_event, camera)
                if path:
                    captured_image_path[0] = path
                    print(f" Image captured: {path}")
                else:
                    print(" Image capture failed.")
            except Exception as e:
                print(f" Error in image capture: {e}")

        def record_video_task():
            try:
                print(" Waiting for human detection to start recording video...")
                path = record_video_if_human(
                    stop_event,
                    camera,
                    max_duration=60,
                    human_detected_event=human_detected_event
                )
                if path:
                    video_filename[0] = path
                    print(f" Video recorded: {path}")
                else:
                    print(" Video recording failed.")
            except Exception as e:
                print(f" Error in video recording: {e}")

        # Start and join both threads
        image_thread = threading.Thread(target=capture_image_task)
        video_thread = threading.Thread(target=record_video_task)
        image_thread.start()
        video_thread.start()
        image_thread.join()
        video_thread.join()

        if not captured_image_path[0] or not video_filename[0]:
            print(" Image or video was not captured. Skipping rest of pipeline.")
            return

        # Step 2: Record audio
        audio_filename = generate_audio_filename()
        record_audio(stop_event, audio_filename, duration=30)
        print(f" Audio recorded: {audio_filename}")

        # Step 3: Merge audio and video
        merged_output_path = merge_audio_and_video(
            video_filename[0], audio_filename, FINAL_OUTPUT_FOLDER
        )
        print(f" Final video saved to: {merged_output_path}")

        # Step 4: Upload to Drive
        try:
            upload_to_drive(captured_image_path[0])
            upload_video_to_drive(merged_output_path)
            print(" Files uploaded to Google Drive")
        except Exception as e:
            print(f" Upload failed: {e}")
        

        # Step 5: Send alert email
        try:
            send_alert_email(captured_image_path[0], video_filename[0])
            print(" Alert email sent")
        except Exception as e:
            print(f" Email failed: {e}")

        # Update global state with last captured files for `/stop-monitoring`
        state.last_image_path = captured_image_path[0]
        state.last_video_path = merged_output_path

        # Cleanup
        cv2.destroyAllWindows()
        print(" Sleeping for 60 seconds before restarting the capture cycle...")
        time.sleep(60)
