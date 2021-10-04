extends Node2D

signal quit

onready var sound = get_tree().get_root().get_node("Sound")
onready var globals = get_tree().get_root().get_node("GlobalVariables")

func _ready():
	var _discard = $VBoxContainer/Menu.connect(
		"button_up", self, "emit_signal", ["quit"])
	_discard = $VBoxContainer/Menu.connect("mouse_entered", sound, "play_button_hover")
	_discard = $VBoxContainer/Menu.connect("button_up", sound, "play_button_press")
