extends RigidBody2D

signal screen_exited
signal play_sound

signal jump_anim
signal land_anim

const JUMP_IMPULSE = 100.0
const GROUND_POUND_IMPULSE = 50.0
const TORQUE_IMPULSE = 200.0
const JUMP_ANGLE = PI / 16.0
const AIR_CONTROL_IMPULSE = 1.0
const MIN_AIRBORNE_TIME = 0.15

var airborne_time = 1e20

var game_ended = false
var has_jumped = true # player spawns in the air

func _ready():
	$VisibilityNotifier2D.connect("screen_exited", self, "emit_signal", ["screen_exited"])

func _physics_process(delta):
	if game_ended:
		return

	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	var ground_pound = Input.is_action_pressed("ground_pound")

	if move_left and not move_right:
		apply_torque_impulse(-TORQUE_IMPULSE)
	if move_right and not move_left:
		apply_torque_impulse(TORQUE_IMPULSE)

	var on_floor = false
	for obj in get_colliding_bodies():
		if obj.is_in_group("Floor"):
			if has_jumped:
				emit_signal("land_anim")
				play_sound("thud")
			on_floor = true
			has_jumped = false

	if on_floor:
		airborne_time = 0.0
		if jump:
			play_sound("jump")
			emit_signal("jump_anim")
			has_jumped = true
			
			if move_left and not move_right:
				apply_impulse(Vector2.ZERO, Vector2.UP.rotated(-JUMP_ANGLE) * JUMP_IMPULSE)
			elif move_right and not move_left:
				apply_impulse(Vector2.ZERO, Vector2.UP.rotated(JUMP_ANGLE) * JUMP_IMPULSE)
			else:
				apply_impulse(Vector2.ZERO, Vector2.UP * JUMP_IMPULSE)
	else:
		airborne_time += delta
		if move_left and not move_right:
			apply_impulse(Vector2.ZERO, Vector2.LEFT * AIR_CONTROL_IMPULSE)
		elif move_right and not move_left:
			apply_impulse(Vector2.ZERO, Vector2.RIGHT * AIR_CONTROL_IMPULSE)
		if ground_pound:
			if airborne_time > MIN_AIRBORNE_TIME:
				play_sound("whoosh")
			apply_impulse(Vector2.ZERO, Vector2.DOWN * GROUND_POUND_IMPULSE)

func play_sound(sound_string):
	emit_signal("play_sound", sound_string)
