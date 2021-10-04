extends Node2D

var sound_library = {
	"jump": ["res://assets/sounds/jump.wav", -10],
	"thud": ["res://assets/sounds/thud.wav", -8],
	"whoosh": ["res://assets/sounds/whoosh.wav", -5],
}

var stream_library = {}
var current_music

func _ready():
	for key in sound_library:
		var sound_node = AudioStreamPlayer.new()
		var stream  = load(sound_library[key][0])
		sound_node.set_stream(stream)
		sound_node.volume_db = sound_library[key][1]
		sound_node.set_bus("FX")
		add_child(sound_node)
		stream_library[key] = sound_node

func play_sound(sound_str):
	if sound_str in stream_library:
		if not stream_library[sound_str].is_playing():
			stream_library[sound_str].play()
