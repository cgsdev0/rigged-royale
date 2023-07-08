extends Node


var outer_circle = null
var inner_circle = null


var sizes = [
	400.0,
	300.0,
	200.0,
	100.0,
	40.0
]
# Called when the node enters the scene tree for the first time.
func _ready():
	var r = sizes[0] / 2.0
	inner_circle = { "radius": r, "position": Vector2(randf_range(r, 512 - r), randf_range(r, 512 - r)) }

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !outer_circle:
		var r = sizes[0] / 2.0
		outer_circle = { "radius": r, "position": Vector2(randf_range(r, 512 - r), randf_range(r, 512 - r)) }
	pass
