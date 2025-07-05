import os
import mimetypes
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

# Initialize Google Drive authentication only once
gauth = GoogleAuth()
gauth.LoadCredentialsFile("credentials.json")

if gauth.credentials is None:
    gauth.LocalWebserverAuth()
elif gauth.access_token_expired:
    gauth.Refresh()
else:
    gauth.Authorize()

gauth.SaveCredentialsFile("credentials.json")
drive = GoogleDrive(gauth)

import time

def upload_video_to_drive(file_path):
    for attempt in range(2):  # 1 retry
        try:
            file_name = os.path.basename(file_path)
            mimetype = mimetypes.guess_type(file_path)[0]

            file_drive = drive.CreateFile({'title': file_name, 'mimeType': mimetype})
            file_drive.SetContentFile(file_path)
            file_drive.Upload()  # Upload may fail

            file_drive.InsertPermission({
                'type': 'anyone',
                'value': 'anyone',
                'role': 'reader'
            })

            video_link = file_drive['alternateLink']
            print(f"[uploading]  Video uploaded successfully: {video_link}")
            return file_name, video_link

        except Exception as e:
            print(f"[upload error]  Attempt {attempt + 1}: {e}")
            time.sleep(3)  # Wait before retry

    return None, None
