extends Node2D

signal start_game
signal start_credits

#onready var audio = get_tree().get_root().get_node("Audio")

onready var globals = get_tree().get_root().get_node("GlobalVariables")

func _ready():
	var _discard = $VBoxContainer/Track1.connect(
		"button_up", self, "start_track1")
	_discard = $VBoxContainer/Track2.connect(
		"button_up", self, "start_track2")
	_discard = $VBoxContainer/Track3.connect(
		"button_up", self, "start_track3")
	_discard = $VBoxContainer/Credits.connect(
		"button_up", self, "start_credits")

func start_track1():
	globals.track_idx = 0
	emit_signal("start_game")

func start_track2():
	globals.track_idx = 1
	emit_signal("start_game")

func start_track3():
	globals.track_idx = 2
	emit_signal("start_game")

func start_credits():
#	audio.play_sound("blip")
	emit_signal("start_credits")
