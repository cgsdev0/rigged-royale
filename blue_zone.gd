extends MeshInstance3D


var mat

@export var inner = false

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = mesh.surface_get_material(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var p
	var r
	if inner:
		if CircleZone.busy || CircleZone.is_done_shrinking():
			visible = false
			return
		else:
			visible = true
		p = CircleZone.icp
		r = CircleZone.icr
	else:
		p = CircleZone.ocp
		r = CircleZone.ocr
		
	if r:
		p.y = -p.y
		p.x = 512.0 - p.x
		mat.set_shader_parameter("radius", r / 512.0)
		mat.set_shader_parameter("position", p / 512.0)
		visible = true
	else:
		visible = false
