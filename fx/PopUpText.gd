extends Node2D

const TWEEN_TIME = 0.6

func _ready():
	scale = Vector2.ZERO
	$Tween.interpolate_property(
		self,
		"scale",
		Vector2.ZERO,
		3*Vector2.ONE,
		TWEEN_TIME,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		TWEEN_TIME,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN
	)
	$Tween.connect(
		"tween_all_completed",
		self,
		"queue_free"
	)
	$Tween.start()

func set_text(input_value):
	$Label.text = input_value
