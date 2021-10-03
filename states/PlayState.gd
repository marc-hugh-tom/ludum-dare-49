extends Node2D

const MAX_ANGLE = PI / 4.0
const MIN_ANGLE_DIFF = PI / 8.0
const N_DETECTION_AREAS = 3
const SCORE_MULTIPLIER = 5
const PLAYER_SPAWN_POINT = Vector2(512, -30)

const packed_detection_area = preload("res://detection/DetectionArea.tscn")
const packed_popuptext = preload("res://fx/PopUpText.tscn")
const packed_player = preload("res://player/PlayerRotate.tscn")

var current_score = 0
var angle = 0

func _ready():
	randomize()
	add_detection_areas()
	$Timer.connect("timeout", self, "detect_and_add_new_areas")
	$Entities/PlayerRotate.connect("screen_exited", self, "spawn_new_player")

func add_detection_areas():
	var new_angle = rand_range(-MAX_ANGLE, MAX_ANGLE)
	while abs(new_angle-angle) < MIN_ANGLE_DIFF:
		new_angle = rand_range(-MAX_ANGLE, MAX_ANGLE)
	angle = new_angle
	var area_height = null
	for i in range(N_DETECTION_AREAS+1):
		var dirs = [1]
		if i > 0:
			dirs.append(-1)
		for dir in dirs:
			var area = packed_detection_area.instance()
			if not area_height:
				area_height = area.get_node("CollisionShape2D").shape.extents.y * 2.0
			area.position = (
				$Platform.position +
				Vector2.UP.rotated(angle) * i * dir * area_height
			)
			area.rotate(angle)
			area.set_i(i)
			$DetectionAreas.add_child(area)
	$DetectionAreaMask.update_strips($DetectionAreas.get_children())

func detect_score():
	var max_i = 0
	for area in $DetectionAreas.get_children():
		if $Platform/Seesaw in area.get_overlapping_bodies():
			max_i = max(max_i, area.get_i())
		area.queue_free()
	var score = SCORE_MULTIPLIER * (N_DETECTION_AREAS - max_i)
	update_score(score)
	if score > 0:
		popup_text(str(score), $Platform.position)
	if max_i == 0:
		popup_text("PERFECT!", $Entities/PlayerRotate.position)
	elif max_i == 1:
		popup_text("GOOD", $Entities/PlayerRotate.position)

func detect_and_add_new_areas():
	detect_score()
	add_detection_areas()

func update_score(input_score):
	current_score += input_score
	$ScoreLabel.text = str(current_score)

func _process(delta):
	$TimerLabel.text = str(round($Timer.get_time_left()))

func popup_text(text, position):
	var popuptext = packed_popuptext.instance()
	popuptext.set_text(text)
	$TopFX.add_child(popuptext)
	popuptext.position = position

func spawn_new_player():
	$Entities/PlayerRotate.queue_free()
	$Entities.remove_child($Entities/PlayerRotate)
	var player = packed_player.instance()
	player.position = PLAYER_SPAWN_POINT
	$Entities.add_child(player)
	player.connect("screen_exited", self, "spawn_new_player")
