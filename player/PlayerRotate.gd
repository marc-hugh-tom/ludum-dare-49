extends RigidBody2D

const JUMP_IMPULSE = 100.0
const GROUND_POUND_IMPULSE = 50.0
const TORQUE_IMPULSE = 200.0

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
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
			on_floor = true

	if on_floor:
		if jump:
			apply_impulse(Vector2.ZERO, Vector2.UP * JUMP_IMPULSE)
	else:
		if ground_pound:
			apply_impulse(Vector2.ZERO, Vector2.DOWN * GROUND_POUND_IMPULSE)
