import cv2

# Initialize HOG detector globally when module loads
hog = cv2.HOGDescriptor()
hog.setSVMDetector(cv2.HOGDescriptor_getDefaultPeopleDetector())

def is_human_detected(frame):
    """
    Checks if a human is detected in the given frame.
    Returns True if human is detected, False otherwise.
    """
    resized = cv2.resize(frame, (640, 480))
    (regions, _) = hog.detectMultiScale(
        resized, winStride=(4, 4), padding=(8, 8), scale=1.05
    )
    return len(regions) > 0
