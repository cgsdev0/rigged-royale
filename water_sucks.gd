extends NavigationRegion3D


var water_height = 30
var above: Array[PackedInt32Array] = [] 
var below: Array[PackedInt32Array] = [] 

# Called when the node enters the scene tree for the first time.
func _ready():
	var vertices = navigation_mesh.get_vertices()
	for i in range(navigation_mesh.get_polygon_count()):
		var polygon = navigation_mesh.get_polygon(i)
		if vertices[polygon[0]].y < water_height || vertices[polygon[1]].y < water_height || vertices[polygon[2]].y < water_height:
			below.push_back(polygon)
		else:
			above.push_back(polygon)
		
#	navigation_mesh.clear_polygons()
##	for polygon in above:
##		navigation_mesh.add_polygon(above)
#
#	var water_3d_region_rid: RID = NavigationServer3D.region_create()
#
#	var default_3d_map_rid: RID = get_world_3d().get_navigation_map()
#	NavigationServer3D.region_set_map(water_3d_region_rid, default_3d_map_rid)
#
#	var new_navigation_mesh: NavigationMesh = NavigationMesh.new()
#	var water_navigation_mesh: NavigationMesh = NavigationMesh.new()
#	new_navigation_mesh.vertices = vertices
#	water_navigation_mesh.vertices = vertices
#	for polygon in above:
#		new_navigation_mesh.add_polygon(polygon)
#	for polygon in below:
#		water_navigation_mesh.add_polygon(polygon)
#
#	NavigationServer3D.region_set_navigation_mesh(water_3d_region_rid, water_navigation_mesh)
#	NavigationServer3D.region_set_enter_cost(water_3d_region_rid, 0)
#	NavigationServer3D.region_set_travel_cost(water_3d_region_rid, 2.5)
#
#
#	navigation_mesh = new_navigation_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
