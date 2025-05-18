from flask import Flask, request, jsonify
import requests
from pydub import AudioSegment

app = Flask(__name__)

@app.route('/generate_audio', methods=['POST'])
def generate_audio():
    # Receive text data from the request
    text_data = request.json.get('text')

    # Call Elevenlabs API to generate audio
    url = "https://api.elevenlabs.io/v1/text-to-speech/cpJNBy5HMc0iauCaBqZT"
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

    # Convert audio content to OGG format
    audio_content = AudioSegment.from_mp3(response.content)
    ogg_content = audio_content.export(format="ogg")

    # Save audio to file
    file_path = 'output.ogg'
    with open(file_path, 'wb') as f:
        f.write(ogg_content)

    # Return the file path
    return jsonify({'file_path': file_path})

if __name__ == '__main__':
    app.run(debug=True, port=6009)