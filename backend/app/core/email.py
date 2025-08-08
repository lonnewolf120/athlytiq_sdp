import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings
# import logging
async def send_email(to_email: str, subject: str, body: str):
    smtp_user = settings.EMAIL_USERNAME
    sender_email = settings.EMAIL_SENDER
    smtp_pass = settings.EMAIL_PASSWORD
    smtp_server = settings.EMAIL_HOST
    smtp_port = settings.EMAIL_PORT

    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = to_email
    message["Subject"] = subject

    message.attach(MIMEText(body, "plain"))

    # logger = logging.getLogger("app.core.email")

    try:
        print(f"Connecting to SMTP server {smtp_server}:{smtp_port}")
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            print("Connected to SMTP server successfully.")
            starttls()
            print("Started TLS session with SMTP ")
            login(smtp_user, smtp_pass)
            print("Logged in to SMTP server successfully.")
            sendmail(sender_email, to_email, message.as_string())
        print(f"Email sent successfully to {to_email}")
        return True
    except smtplib.SMTPAuthenticationError as e:
        print(f"SMTP Authentication Error: Could not authenticate with the SMTP  Check username and password. Error: {e}")
        return False
    except smtplib.SMTPConnectError as e:
        print(f"SMTP Connection Error: Could not connect to the SMTP  Check host and port. Error: {e}")
        return False
    except smtplib.SMTPException as e:
        print(f"SMTP Error: An SMTP error occurred while sending email to {to_email}. Error: {e}")
        return False
    except Exception as e:
        print(f"General Error: An unexpected error occurred while sending email to {to_email}. Error: {e}")
        return False
