extends Area2D

signal overlap_change

var i = 0
var overlapping = false

func _ready():
	connect("body_entered", self, "body_entered_callback")
	connect("body_exited", self, "body_exited_callback")

func set_i(input_val):
	i = input_val

func get_i():
	return(i)

func is_overlapping():
	return(overlapping)

func body_entered_callback(body):
	if body.is_in_group("Floor"):
		overlapping = true
		emit_signal("overlap_change")

func body_exited_callback(body):
	if body.is_in_group("Floor"):
		overlapping = false
		emit_signal("overlap_change")
