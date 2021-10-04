extends Node2D

func _ready():
	$PlayerRotate.connect("jump_anim", $AnimationPlayer, "play", ["jump"])
	$PlayerRotate.connect("land_anim", $AnimationPlayer, "play", ["land"])

func _process(delta):
	if is_instance_valid($SpriteParent) and is_instance_valid($PlayerRotate):
		$SpriteParent/SpriteOffset/Sprite.rotation = $PlayerRotate.rotation
		$SpriteParent.position = $PlayerRotate.position
