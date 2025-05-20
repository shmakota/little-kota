# little-kota

![image](https://github.com/user-attachments/assets/ab02040f-c687-46f4-8fda-ed213f0f633a)

**little-kota** is an experimental [Godot Engine](https://godotengine.org/) project that integrates with Python and [Ollama](https://ollama.com/) to enable immersive, character-driven conversations with a local LLM (Large Language Model). The user interacts with a character in a 3D space and receives spoken or text-based responses, giving the feel of a real-time AI companion.

## Features

- 🧠 **LLM-Driven Dialogue**: Connects to local LLMs via Ollama to generate realistic, character-based responses.
- 🗣️ **Voice Input/Output**: Speak to characters using your microphone and receive audible responses (TTS integration).
- 🎮 **Modular Content Support**: Supports dynamic loading of custom avatars, environments, and other assets using `.PCK` mod files.
- 🧩 **Python Integration**: Leverages Python scripts to handle communication with the LLM and additional logic.
- 🌍 **Interactive Maps & Avatars**: Easily expand your world with custom characters, NPCs, and scenes.
- 🕹️ **Immersive Experience**: Designed to blend LLM interactivity with a game-like environment for storytelling, RP, or AI-driven exploration.

## Getting Started

### Prerequisites

- Godot 4.5dev3
- Python 3.10+
- Ollama with a compatible LLM installed

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/little-kota.git
   cd little-kota
   ```
2. Install Python dependencies (preferrable in a venv):
   ```bash
   pip install -r requirements.txt
   ```

4. Launch Ollama and ensure your model is running:
   ```bash
   ollama run nemotron-mini:4b
   ```

5. Launch the local speech recognition & speech synthesis server:
   ```bash
   ./start_server.sh
   ```

6. Open the project in Godot and run it. You will need a .PCK avatar in your user directory to speak to an avatar.
