import time
import cv2
import datetime
import os
from constants import generate_video_filename
from detect.human_detector import is_human_detected 

def record_video_if_human(stop_event, camera, max_duration=60, filename=None, human_detected_event=None):
    print(" Scanning for human presence...")

    # Wait for human detection to trigger video recording
    while not stop_event.is_set():
        ret, frame = camera.read()
        if not ret:
            print(" Failed to grab frame, retrying...")
            continue

        # Detect if a human is present
        if is_human_detected(frame):
            print(" Human detected! Starting video recording...")
            if human_detected_event and not human_detected_event.is_set():
                human_detected_event.set()  # Signal image thread that human is present
                print(" Signaled image thread that human is present.")
            break
        else:
            print(" No human detected yet.")
        cv2.waitKey(1)

    # If no filename is provided, generate one
    if not filename:
        filename = generate_video_filename()

    os.makedirs(os.path.dirname(filename), exist_ok=True)
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(filename, fourcc, 20.0, (640, 480))

    start_time = time.time()
    last_seen_time = time.time()

    # Start recording video after detecting human
    while not stop_event.is_set():
        ret, frame = camera.read()
        if not ret:
            print("Lost camera feed during recording.")
            break

        frame_resized = cv2.resize(frame, (640, 480))  # Ensure frame size matches VideoWriter resolution
        out.write(frame_resized)
        cv2.imshow("Recording...", frame_resized)

        if is_human_detected(frame):
            last_seen_time = time.time()
        elif time.time() - last_seen_time > 5:
            print("Human left for more than 5 seconds. Stopping.")
            break

        if time.time() - start_time >= max_duration:
            print(" Max recording time reached. Stopping.")
            break

        if cv2.waitKey(1) & 0xFF == ord('q'):
            print(" Quit key pressed.")
            break

    out.release()
    cv2.destroyAllWindows()
    print(f" Video saved to: {os.path.abspath(filename)}")
    return filename
