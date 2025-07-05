import os
import cloudinary.uploader
import cloudinary

cloudinary.config(
    cloud_name="smartcarsecurity",
    api_key="567317897731269",
    api_secret="6tTzofGbGgWisL25HNhXIjo4kDY",
    secure=True
)

def upload_file_to_cloudinary(file_path):
    try:
        # Ensure file exists before uploading
        if not os.path.exists(file_path):
            print(f" File does not exist: {file_path}")
            return None
        
        # Determine resource type based on file extension
        extension = os.path.splitext(file_path)[1].lower()
        if extension in [".mp4", ".mov", ".avi", ".mkv", ".mp3", ".wav", ".aac"]:
            resource_type = "video"
        else:
            resource_type = "image"

        # Upload file to Cloudinary
        result = cloudinary.uploader.upload(file_path, resource_type=resource_type)
        print(f" Uploaded to Cloudinary: {result['secure_url']}")

        return {
            "url": result["secure_url"],
            "public_id": result["public_id"]
        }

    except Exception as e:
        print(f" Cloudinary upload failed: {e}")
        return None
import cloudinary.uploader

def delete_single_file(public_id, file_type):
    try:
        # Delete the media from Cloudinary based on public_id and file_type
        if file_type == 'image':
            result = cloudinary.uploader.destroy(public_id, resource_type="image")
        else:
            result = cloudinary.uploader.destroy(public_id, resource_type="video")
        
        return result
    except Exception as e:
        return {"result": "error", "message": str(e)}
