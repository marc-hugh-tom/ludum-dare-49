extends Node2D

var colours = [
	"95C5AC",
	"69809E",
	"4C5C87"
]

var strips = []

func _ready():
	pass

func _physics_process(delta):
	update()

func _draw():
	for strip in strips:
		var i = strip["area"].get_i()
		if i < len(colours):
			var colour = colours[i]
			if strip["area"].is_overlapping():
				colour = "#FF" + colour
			else:
				colour = "#77" + colour
			draw_polygon(
				strip["points"],
				PoolColorArray([colour])
			)

func clear_strips():
	strips = []

func add_strip(area):
	var extents = area.get_node("CollisionShape2D").shape.extents
	extents.x *=2
	strips.append(
		{
			"points": PoolVector2Array(
				[
					area.position + extents.rotated(area.rotation),
					area.position + extents.reflect(Vector2.UP).rotated(area.rotation),
					area.position + extents.rotated(PI).rotated(area.rotation),
					area.position + extents.reflect(Vector2.RIGHT).rotated(area.rotation)
				]
			),
			"area": area
		}
	)

func update_strips(areas):
	clear_strips()
	for area in areas:
		if not area.is_queued_for_deletion():
			add_strip(area)
