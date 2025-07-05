import cloudinary
import cloudinary.uploader  # Explicit import

def delete_single_file(public_id, file_type):
    try:
        if not public_id or not file_type:
            return {"result": "error", "message": "Missing public_id or file_type"}

        resource_type = "video" if file_type.lower() == "video" else "image"
        print(f" Deleting from Cloudinary: public_id='{public_id}', type='{resource_type}'")

        result = cloudinary.uploader.destroy(
            public_id,
            resource_type=resource_type,
            invalidate=True  # Optional: ensures cached URLs are purged
        )
        print(f" Cloudinary response: {result}")
        return result

    except Exception as e:
        print(f" Exception during Cloudinary deletion: {e}")
        return {"result": "error", "message": str(e)}
