#!/bin/bash

# Exit if any command fails
set -e

# Source the Python virtual environment
source py-venv/bin/activate

# Run the Python script
python3 elevenlabs_request_server.py
