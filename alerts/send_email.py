import smtplib
from email.message import EmailMessage
import os
import mimetypes

def send_alert_email(image_path, video_path):
    sender_email = "gkhundal0001@gmail.com"
    receiver_email = "gkhundal00001@gmail.com"
    app_password = "vnrv ntpf neng giva"  # Make sure this is a valid App Password

    subject = "Smart Car Alert 🚗: Motion Detected"
    body = """
    Hello,

    Motion was detected near your car. Please find the attached image and video.

    Stay safe,
    Your Smart Car AI System
    """

    msg = EmailMessage()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = subject
    msg.set_content(body)

    # Attach image
    if image_path and os.path.exists(image_path):
        with open(image_path, 'rb') as img_file:
            img_data = img_file.read()
            img_name = os.path.basename(image_path)
            img_type = mimetypes.guess_type(image_path)[0] or 'application/octet-stream'
            maintype, subtype = img_type.split('/')
            msg.add_attachment(img_data, maintype=maintype, subtype=subtype, filename=img_name)

    # Attach video
    if video_path and os.path.exists(video_path):
        with open(video_path, 'rb') as vid_file:
            vid_data = vid_file.read()
            vid_name = os.path.basename(video_path)
            vid_type = mimetypes.guess_type(video_path)[0] or 'application/octet-stream'
            maintype, subtype = vid_type.split('/')
            msg.add_attachment(vid_data, maintype=maintype, subtype=subtype, filename=vid_name)

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
            smtp.login(sender_email, app_password)
            smtp.send_message(msg)
        print("📧 Email with attachments sent successfully.")
    except Exception as e:
        print(f"❌ Failed to send email with attachments: {e}")
