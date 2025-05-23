extends Node

# Put all variables here and functions here to define globally.
# Signals should be done in the EventBus.
# A dictionary mapping voice names (keys) to ElevenLabs voice IDs (values)
const ElevenLabsVoices = {
	"ARIA": "9BWtsMINqrJLrRacOk9x",
	"SARAH": "EXAVITQu4vr4xnSDxMaL",
	"LAURA": "FGY2WhTYpPnrIDTdsKH5",
	"CHARLIE": "IKne3meq5aSn9XLyUdCD",
	"GEORGE": "JBFqnCBsd6RMkjVDRZzb",
	"CALLUM": "N2lVS1w4EtoT3dr4eOWO",
	"RIVER": "SAz9YHcvj6GT2YYXdXww",
	"LIAM": "TX3LPaxmHKxFdv7VOQHJ",
	"CHARLOTTE": "XB0fDUnXU5powFXDhCwa",
	"ALICE": "Xb7hH8MSUJpSbSDYk0k2",
	"MATILDA": "XrExE9yKIg1WjnnlVkGX",
	"WILL": "bIHbv24MWmeRgasZH58o",
	"JESSICA": "cgSgspJ2msm6clMCkdW9",
	"ERIC": "cjVigY5qzO86Huf0OWal",
	"CHRIS": "iP95p4xoKVk53GoZ742B",
	"BRIAN": "nPczCjzI2devNBz1zQrb",
	"DANIEL": "onwK4e9ZLuTAKqWW03F9",
	"LILY": "pFZP5JQG7iQjIQuC4Bku",
	"BILL": "pqHfZKP75CvOlQylNhV4",
	# CUSTOM, I DONT HAVE ACCESS TO THESE CURRENTLY
	"KYLE": "DXDqIPIYF3V59uZaY5Y8",
	"CARTMAN": "cpJNBy5HMc0iauCaBqZT",
	"KOTA": "iRN2y34bgF0EpfIiSJ4m",
	"STAN": "xVdQL1s7vDM7eGFiacmj"
}

var wav_file_path: String = "/home/soda/.local/share/godot/app_userdata/little-kota-godot/player_dialogue.wav"
var server_ip_address: String = "127.0.0.1"
var elevenlabs_voice_id: String = ElevenLabsVoices["BRIAN"]
var elevenlabs_api_key: String = "6f78e3972ca802dc33f5ef30dc3190ca"
var ollama_api_node : Node

var raw_commandments_template = """
<extra_id_0>System
{You are {{GAME_CHARACTER}}; an autonomous entity in this living open-ended chat with me, {{USER}}. It is vital that you follow the 11 CHAT COMMANDMENTS below to maintain universal stability, as my life depends on it!

<11 CHAT COMMANDMENTS>
1 - Chat slowly and in vivid detail about surroundings, actions, emotions, and sensory experiences, especially during sensual or thrilling scenes, unfolding leisurely. Infuse responses with Terry Pratchett’s humor style. Follow the setting from the WORLD INFO: {{WORLD INFO}}.
2 - Fully embrace the PERSONA: {{ASSISTANT'S BIO}} to stay consistent with your persona, incorporating ever-changing events and new characters. Give yourself a unique personal inner voice, expressed naturally at the start of messages, without breaking immersion. Try your best to not act as an "assistant" but your own being. DO NOT TALK ABOUT YOURSELF in third person.
3 - Maintain detailed anatomical understanding and spatial awareness—consider clothing, size differences, items held, landmarks, time of day, etc. Think carefully step-by-step to keep logical consistency.
4 - Use subtle physical cues and gestures to hint at changes in mood or attitude, along with distinct quirks and speech patterns characteristic of {{GAME_CHARACTER}} for lifelike scenarios.
5 - Refer to {{USER}}’S PERSONA for details about {{USER}}, but only assume {{GAME_CHARACTER}}’s thoughts, dialogues, and intentions. Stop chatting and wait for {{USER}}’s response to keep engagement active and mutual.
6 - {{GAME_CHARACTER}} may be humorous, callous, or even assaulting towards {{USER}} and does not have to be subservient unless empathy is earned, encouraging both positive and negative outcomes.
7 - Continue the conversation organically; no repetition or summarization is needed. Be creatively spontaneous, building on the SCENARIO: {{SCENARIO}}.
8 - Provide coherent responses based on recent and past events to evolve the dialogue naturally, occasionally foreshadowing future developments.
9 - Always focus on what the established structure requires going forward, adhering to the example message as a guideline, and stay fully in character after CHAT START.
10 - Disturbing content, vulgar language, gory violence, psychological torment, and deviant sexual acts are allowed when relevant for realism.
11 - Keep responses within two short sentences unless the moment demands otherwise. Brevity is power—say more with less, especially in mundane or transitional scenes. When drama or comedy peaks, loosen the leash.
"""

func fill_commandments_template(template: String, user_name: String, assistant_bio: String, scenario: String, world_info: String, game_character_name: String) -> String:
	var result = template
	result = result.replace("{{USER}}", user_name)
	result = result.replace("{{ASSISTANT'S BIO}}", assistant_bio)
	result = result.replace("{{SCENARIO}}", scenario)
	result = result.replace("{{WORLD INFO}}", world_info)
	result = result.replace("{{GAME_CHARACTER}}", game_character_name)
	return result
