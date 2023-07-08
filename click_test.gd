extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = preload("res://player.tscn")
	for i in range(100):
		var p = player.instantiate()
		add_child(p)
		p.global_position.z = randf_range(-600, 0)
		p.global_position.x = randf_range(0, 600)
		p.global_position.y = 60.0
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.is_pressed():
			var from = project_ray_origin(event.position)
			from.y = 60
			for character in get_tree().get_nodes_in_group("player"):
				character.plot_course(from)
			
