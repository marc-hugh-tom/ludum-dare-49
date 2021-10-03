extends Node2D


signal quit

func _ready():
	$MainViewport/Viewport.connect("quit", self, "emit_signal", ["quit"])
