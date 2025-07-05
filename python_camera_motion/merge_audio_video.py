import os
from moviepy.editor import VideoFileClip, AudioFileClip

from threading import Thread
from upload.upload_final_merged_video import upload_video_to_drive

def merge_audio_and_video(video_file, audio_file, output_dir):
    try:
        # Check if both video and audio exist
        if not os.path.isfile(video_file):
            print(f" Video file not found: {video_file}")
            return None  # Return None if video file is not found
        if not os.path.isfile(audio_file):
            print(f" Audio file not found: {audio_file}")
            return None  # Return None if audio file is not found

        # Ensure output directory exists
        os.makedirs(output_dir, exist_ok=True)

        # Build output filename based on video file
        base_name = os.path.splitext(os.path.basename(video_file))[0]
        output_file = os.path.join(output_dir, f"{base_name}_merged.mp4")

        print(f" Merging audio and video:\n {video_file}\n {audio_file}\n {output_file}")

        # Load video and audio
        video_clip = VideoFileClip(video_file)
        audio_clip = AudioFileClip(audio_file)

        # Combine and export
        final_clip = video_clip.set_audio(audio_clip)
        final_clip.write_videofile(output_file, codec='libx264', audio_codec='aac')

        print(f" Merge complete. Video saved to: {output_file}")

        # Upload in background
        Thread(target=upload_video_to_drive, args=(output_file,)).start()

        # Return the path of the merged video
        return output_file

    except Exception as e:
        print(f" Error during merging: {e}")
        return None  # Return None if there's an error during the process
