extends RigidBody2D

const WALK_ACCEL = 500.0
const WALK_DEACCEL = 500.0
const WALK_MAX_VELOCITY = 140.0

const AIR_ACCEL = 100.0
const AIR_DEACCEL = 100.0

const JUMP_VELOCITY = 120.0
const STOP_JUMP_FORCE = 450.0
const MAX_FLOOR_AIRBORNE_TIME = 0.15

var jumping = false
var stopping_jump = false
var airborne_time = 1e20

func _ready():
	pass # Replace with function body.

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()

	# Get player input.
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")

	# Find the floor (a contact with upwards facing collision normal).
	var found_floor = false
	var floor_normal = null

	for x in range(s.get_contact_count()):
		var obj = s.get_contact_collider_object(x)
		if obj.is_in_group("Floor"):
			found_floor = true
			floor_normal = s.get_contact_local_normal(x)

	# Process jump.
	if jumping:
		if lv.y > 0:
			# Set off the jumping flag if going down.
			jumping = false
		elif not jump:
			stopping_jump = true

		if stopping_jump:
			lv.y += STOP_JUMP_FORCE * step

	if found_floor:
#		print(Vector2.UP.dot(floor_normal))
		# Process logic when character is on floor.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
#				print("left: ", -floor_normal.rotated(PI/2))
				lv -= floor_normal.rotated(PI/2) * WALK_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
#				print("right: ", floor_normal.rotated(PI/2))
				lv += floor_normal.rotated(PI/2) * WALK_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv

		# Check jump.
		if not jumping and jump:
			lv.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false

	else:
		# Process logic when the character is in the air.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += AIR_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEACCEL * step

			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv

	# Finally, apply gravity and set back the linear velocity.
	lv += s.get_total_gravity() * step
	s.set_linear_velocity(lv)
