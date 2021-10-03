extends Viewport

signal quit

const MAX_ANGLE = PI / 4.0
const MIN_ANGLE_DIFF = PI / 8.0
const N_DETECTION_AREAS = 3
const SCORE_MULTIPLIER = 5
const PLAYER_SPAWN_POINT = Vector2(512, -30)

const FREQ_MIN = 0.0
const FREQ_MAX = 11050.0
const MIN_DB = 60
const ENERGY_SPEED = 10.0

const packed_detection_area = preload("res://detection/DetectionArea.tscn")
const packed_popuptext = preload("res://fx/PopUpText.tscn")
const packed_player = preload("res://player/PlayerRotate.tscn")

var current_score = 0
var angle = 0
var spectrum
var energy = 0
var target_energy = 0
var game_ended = false

onready var globals = get_tree().get_root().get_node("GlobalVariables")

func _ready():
	randomize()
	add_detection_areas()
	$Timer.connect("timeout", self, "detect_and_add_new_areas")
	$Entities/PlayerRotate.connect("screen_exited", self, "spawn_new_player")
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	load_track()

func load_track():
	$Music.stream = globals.tracks[globals.track_idx]["mp3"]
	$Music.connect("finished", self, "show_end_menu")
	$Music.play()

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
	if not game_ended:
		detect_score()
		add_detection_areas()

func update_score(input_score):
	current_score += input_score
	$ScoreLabel.text = str(current_score)

func _process(delta):
	if not game_ended:
		update_timer()
		update_energy(delta)

func update_timer():
	$Stopper/Sprite.material.set_shader_param("t", $Timer.get_time_left() / $Timer.get_wait_time())

func update_energy(delta):
	var magnitude = spectrum.get_magnitude_for_frequency_range(FREQ_MIN, FREQ_MAX).length()
	target_energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
	energy += (target_energy-energy) * delta * ENERGY_SPEED
	get_parent().material.set_shader_param("energy", energy)

func popup_text(text, position):
	var popuptext = packed_popuptext.instance()
	popuptext.set_text(text)
	$TopFX.add_child(popuptext)
	popuptext.position = position

func spawn_new_player():
	if not game_ended:
		var old_player = $Entities/PlayerRotate
		old_player.queue_free()
		var player = packed_player.instance()
		player.position = PLAYER_SPAWN_POINT
		$Entities.call_deferred("add_child", player)
		player.connect("screen_exited", self, "spawn_new_player")

func show_end_menu():
	var end_menu = get_parent().get_parent().get_node("EndMenu")
	end_menu.get_node("VBoxContainer/Score").text = str(current_score)
	end_menu.show()
	game_ended = true
	$Entities/PlayerRotate.game_ended = true
	end_menu.get_node("VBoxContainer/Menu").connect("button_up", self,
		"emit_signal", ["quit"])
	end_menu.get_node("VBoxContainer/Tweet").connect("button_up", self,
		"tweet")

func tweet():
	var _return = OS.shell_open("http://twitter.com/share?text=" +
		"I scored " + str(current_score) + " in Roller Disco while listening to" +
		" Loyalty Freak Music's " + globals.tracks[globals.track_idx]["name"] + "!&url=" +
		"https://manicmoleman.itch.io/roller-disco" +
		"&hashtags=LD49,LDJAM,GodotEngine")
