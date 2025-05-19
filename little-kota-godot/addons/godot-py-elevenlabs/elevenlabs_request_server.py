from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import requests
from pydub import AudioSegment
from io import BytesIO
import time
import os

PORT = 6003  # Change this if needed
print("Elevenlabs Request Server Loaded")

class AudioHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length)
            data = json.loads(body)
            text_data = data.get("text", "")
            if not text_data:
                raise ValueError("Missing 'text' field")

            file_path = self.save_audio_file(text_data)
            if not file_path:
                raise RuntimeError("Audio generation failed")

            with open(file_path, 'rb') as f:
                audio_data = f.read()

            self.send_response(200)
            self.send_header("Content-Type", "audio/ogg")
            self.send_header("Content-Length", str(len(audio_data)))
            self.send_header("Access-Control-Allow-Origin", "*")  # optional for Godot Web
            self.end_headers()
            self.wfile.write(audio_data)

        except Exception as e:
            error_msg = json.dumps({"error": str(e)}).encode()
            self.send_response(400)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(error_msg)))
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(error_msg)


    def log_message(self, format, *args):
        return  # Silence HTTP logs

    def save_audio_file(self, text_data):
        url = "https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM"
        headers = {
            "Accept": "audio/mpeg",
            "Content-Type": "application/json",
            "xi-api-key": "6f78e3972ca802dc33f5ef30dc3190ca"
        }
        data = {
            "text": text_data,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.5
            }
        }

        response = requests.post(url, json=data, headers=headers)
        if response.status_code != 200:
            print("Error from ElevenLabs:", response.text)
            return None

        # Convert MP3 response to OGG and save
        mp3_audio = BytesIO(response.content)
        audio = AudioSegment.from_file(mp3_audio, format="mp3")

        os.makedirs("audio", exist_ok=True)
        filename = f"audio/output_{int(time.time())}.ogg"
        audio.export(filename, format="ogg")
        return filename

def run():
    server_address = ("", PORT)
    httpd = HTTPServer(server_address, AudioHandler)
    print(f"Server running on port {PORT}...")
    httpd.serve_forever()

if __name__ == "__main__":
    run()
