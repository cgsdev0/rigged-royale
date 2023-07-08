extends MeshInstance3D


var mat

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = mesh.surface_get_material(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if CircleZone.outer_circle:
		mat.set_shader_parameter("radius", CircleZone.outer_circle.radius / 512.0)
		mat.set_shader_parameter("position", CircleZone.outer_circle.position / 512.0)
		visible = true
	else:
		visible = false
