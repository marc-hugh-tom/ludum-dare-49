extends Node2D


signal quit

func _ready():
	$MainViewport/Viewport.connect("quit", self, "emit_signal", ["quit"])
	get_viewport().connect("size_changed", self, "viewport_size_changed")
	viewport_size_changed()

func viewport_size_changed():
	var parent_vp = get_viewport()
	var child_vp = $MainViewport/Viewport
	child_vp.set_size(parent_vp.get_size())
	child_vp.set_size_override_stretch(true)
	child_vp.set_size_override(true, parent_vp.get_size_override())
