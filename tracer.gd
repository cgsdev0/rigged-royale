extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var t = get_tree().create_tween()
	t.tween_property(self, "radius", 0.0, 1.0)
	await t.finished
	queue_free()
