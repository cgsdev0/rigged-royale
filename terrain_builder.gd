@tool
extends Node3D

@onready var height_image
@onready var normals_image
@onready var width
@onready var height

var height_data = {}
var normal_data = {}
var terrain_amplitude = 100

var vertices = PackedVector3Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()

var water_height = 49.3

var st = ImmediateMesh.new()

@onready var my_mesh = Mesh.new()
@onready var mesh_resolution = 1
@onready var mesh_container = self

# Called when the node enters the scene tree for the first time.
func _ready():
	create_mesh()
	
func create_mesh():
	height_image = load("res://textures/heightmap.png").get_image()
	normals_image = load("res://textures/normalmap.png").get_image()
	st.clear_surfaces()
	width = height_image.get_width()
	height = height_image.get_height()
	
	var heightmap = height_image
	var normalmap = normals_image
	for x in range(width):
		if x % mesh_resolution == 0:
			for y in range(height):
				if y % mesh_resolution == 0:
						height_data[Vector2(x,y)] = max(water_height, heightmap.get_pixel(x,y).r * terrain_amplitude)
						normal_data[Vector2(x,y)] = normalmap.get_pixel(x,y)
					
	for x in range(width - mesh_resolution):
		if x % mesh_resolution == 0:
			for y in range(height - mesh_resolution):
				if y % mesh_resolution == 0:
					create_quad(x, y, width)
					
	st.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for v in vertices.size():
		st.surface_set_uv(uvs[v])
		st.surface_set_normal(normals[v])
		st.surface_add_vertex(vertices[v])
	
	st.surface_end()
	my_mesh = st
	var mat = preload("res://materials/map.tres")
	my_mesh.surface_set_material(0, mat)
	mesh_container.set_mesh(my_mesh)

func create_quad(x, y, s):
	# triangle 1
	var vert1 = Vector3(x, height_data[Vector2(x,y)], -y)
	var vert2 = Vector3(x, height_data[Vector2(x, y + mesh_resolution)], (-y - mesh_resolution))
	var vert3 = Vector3(x + mesh_resolution, height_data[Vector2(x + mesh_resolution, y + mesh_resolution)], (-y - mesh_resolution))
	
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)

	uvs.push_back(Vector2(vert1.x / s, -vert1.z / s))
	uvs.push_back(Vector2(vert2.x / s, -vert2.z / s))
	uvs.push_back(Vector2(vert3.x / s, -vert3.z / s))
	
	normals.push_back(c_to_v(normal_data[Vector2(x,y)]))
	normals.push_back(c_to_v(normal_data[Vector2(x, y + mesh_resolution)]))
	normals.push_back(c_to_v(normal_data[Vector2(x + mesh_resolution, y + mesh_resolution)]))
	
	# triangle 2
	vert1 = Vector3(x, height_data[Vector2(x,y)],(-y))
	vert2 = Vector3(x + mesh_resolution, height_data[Vector2(x + mesh_resolution, y + mesh_resolution)], (-y - mesh_resolution))
	vert3 = Vector3(x + mesh_resolution, height_data[Vector2(x + mesh_resolution, y)], (-y))
	
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)
	
	uvs.push_back(Vector2(vert1.x / s, -vert1.z / s))
	uvs.push_back(Vector2(vert2.x / s, -vert2.z / s))
	uvs.push_back(Vector2(vert3.x / s, -vert3.z / s))
	
	normals.push_back(c_to_v(normal_data[Vector2(x,y)]))
	normals.push_back(c_to_v(normal_data[Vector2(x + mesh_resolution, y + mesh_resolution)]))
	normals.push_back(c_to_v(normal_data[Vector2(x + mesh_resolution, y)]))
	
func c_to_v(c):
	return Vector3(c.r, c.g, c.b)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
