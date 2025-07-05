from flask import Flask, request
from pydub import AudioSegment
import subprocess
import io
import tempfile
import os
import threading
import time

app = Flask(__name__)

# Function to delete temporary file after a delay (10 seconds)
def delete_later(path, delay=10):
    def _delete():
        time.sleep(delay)
        try:
            os.remove(path)
            print(f"🧹 Deleted temp file: {path}")
        except Exception as e:
            print(f"❌ Could not delete temp file: {e}")
    threading.Thread(target=_delete, daemon=True).start()

@app.route('/upload', methods=['POST'])
def play_audio():
    if 'audio' not in request.files:
        return "❌ No audio file found", 400

    file = request.files['audio']

    try:
        # Read audio file into memory
        file_data = file.read()
        audio = AudioSegment.from_file(io.BytesIO(file_data))

        # Save to a temporary WAV file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as tmp_wav:
            audio.export(tmp_wav.name, format='wav')
            tmp_path = tmp_wav.name

        print(f"▶ Playing temp file: {tmp_path}")

        # Play audio asynchronously using ffplay (no display, auto exit)
        subprocess.Popen(
            ['ffplay', '-nodisp', '-autoexit', tmp_path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

        # Schedule file deletion
        delete_later(tmp_path)

        return "✅ Audio is playing (not saved permanently)", 200

    except Exception as e:
        print(f"❌ Error: {e}")
        return f"❌ Error: {e}", 500

if __name__ == '__main__':
    print("🔊 Audio server running on http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000)
