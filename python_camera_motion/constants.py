from datetime import datetime
# generate timestamp 
def get_timestamp():
    return datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
#paths 
CAPTURE_FOLDER = "capture/"
VIDEO_FOLDER = "video/"
AUDIO_FOLDER = "audio/"
FINAL_OUTPUT_FOLDER = "final_output/"

#file name generators
def generate_image_filename():
    return f"{CAPTURE_FOLDER}capture_"+ get_timestamp() +".jpg"
def generate_video_filename():
    return f"{VIDEO_FOLDER}video_" + get_timestamp() + ".mp4"
def generate_audio_filename():
    return f"{AUDIO_FOLDER}audio_" + get_timestamp() + ".wav"
def generate_final_output_filename():
    return f"{FINAL_OUTPUT_FOLDER}merged_" + get_timestamp()+".mp4"
    