import os
import sounddevice as sd
from scipy.io.wavfile import write

def record_audio(stop_event, filename, duration=30, fs=44100):
    """
    Records audio for a fixed duration regardless of human presence.
    """
    print(f"🎙 Starting audio recording for {duration} seconds...")

    try:
        os.makedirs(os.path.dirname(filename), exist_ok=True)

        # Record audio
        audio = sd.rec(int(duration * fs), samplerate=fs, channels=2)
        sd.wait()  # Wait for the recording to finish

        write(filename, fs, audio)

        # Confirm file saved
        if os.path.exists(filename):
            print(f" Audio file saved: {filename}")
            return filename
        else:
            print(f" Audio file not saved at {filename}")

    except Exception as e:
        print(f" Audio recording failed: {e}")

    return None
