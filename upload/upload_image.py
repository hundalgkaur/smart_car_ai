import os 
import mimetypes
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import sys

# Add the root project directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__))))

# Initialize Google Drive authentication only once
gauth = GoogleAuth()
gauth.LoadCredentialsFile("credentials.json")

if gauth.credentials is None:
    gauth.LocalWebserverAuth()  # Authenticates using a local webserver
elif gauth.access_token_expired:
    gauth.Refresh()  # Refreshes the token if expired
else:
    gauth.Authorize()  # Authorizes with the current credentials

gauth.SaveCredentialsFile("credentials.json")  # Save updated credentials
drive = GoogleDrive(gauth)  # Create a Google Drive instance

def upload_to_drive(file_path):
    try:
        file_name = os.path.basename(file_path)  # Get the file name
        mimetype = mimetypes.guess_type(file_path)[0]  # Guess the MIME type of the file

        # Create a file in Google Drive with title and MIME type
        file_drive = drive.CreateFile({'title': file_name, 'mimeType': mimetype})
        file_drive.SetContentFile(file_path)  # Set the content of the file
        file_drive.Upload()  # Upload the file to Google Drive

        # Make the file publicly accessible
        file_drive.InsertPermission({
            'type': 'anyone',
            'value': 'anyone',
            'role': 'reader'
        })

        file_url = file_drive['alternateLink']  # Get the sharable link
        return file_name, file_url  # Return both file name and file URL

    except Exception as e:
        print(f"[upload error]  Failed to upload image: {e}")
        return None, None  # Return None if there's an error
