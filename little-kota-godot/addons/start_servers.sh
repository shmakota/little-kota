#!/bin/bash
set -e

# Activate virtual environment
source py-venv/bin/activate

# Run both scripts in parallel
python3 godot-py-elevenlabs/elevenlabs_request_server.py &
python3 godot-py-stt/speech-to-text.py &

# Wait for both to finish
wait
