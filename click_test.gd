extends Camera3D

var colors = [
	rgb(206,81,56),
	rgb(51,212,209),
	rgb(193,66,129),
	rgb(94,197,117),
	rgb(143,57,144),
	rgb(132,195,89),
	rgb(115,108,218),
	rgb(186,171,41),
	rgb(73,55,145),
	rgb(76,145,55),
	rgb(216,119,196),
	rgb(68,197,146),
	rgb(211,73,98),
	rgb(72,126,57),
	rgb(195,127,210),
	rgb(193,167,79),
	rgb(109,143,215),
	rgb(204,126,41),
	rgb(118,41,95),
	rgb(187,179,102),
	rgb(217,110,160),
	rgb(124,105,36),
	rgb(164,68,75),
	rgb(218,129,96),
	rgb(132,53,28),
]

var sticky = false
func rgb(r,g,b):
	return Color(r / 255.0, g / 255.0, b / 255.0)

func _ready():
	await get_tree().create_timer(2.0).timeout
	$HumSound.play()
	$KeyboardSound.play()
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($HumSound, "volume_db", -5.0, 3.0)
	tween.tween_property($KeyboardSound, "volume_db", -5.0, 5.0)
	
# Called when the node enters the scene tree for the first time.
func start_the_game():
	$StaticSound.play()
	current = true
	await get_tree().create_timer(0.16).timeout
	$%Static.visible = false
	CircleZone.started = true
	self.call_deferred("spawn_pois")
#	return
	self.call_deferred("spawn")
	#self.call_deferred("visual_circle")
	
var pois = [{ "p": Vector3(436.9383, 51.37256, -79.0124), "r": 10.194164276123 }, { "p": Vector3(399.0123, 49.29999, -160.3951), "r": 38.2107048034668 }, { "p": Vector3(365.8271, 50.5882, -256), "r": 21.9142971038818 }, { "p": Vector3(285.2346, 57.25488, -256.7901), "r": 24.1878223419189 }, { "p": Vector3(261.5309, 50.5882, -183.3087), "r": 15.3686218261719 }, { "p": Vector3(233.8765, 50.76251, -198.321), "r": 20.7475280761719 }, { "p": Vector3(171.4568, 50.19608, -152.4938), "r": 29.6597595214844 }, { "p": Vector3(154.0741, 100, -80.59259), "r": 12.5365800857544 }, { "p": Vector3(56.88889, 55.29407, -271.8024), "r": 19.6829319000244 }, { "p": Vector3(134.321, 50.5882, -299.4568), "r": 18.5297794342041 }, { "p": Vector3(229.9259, 50.19608, -402.963), "r": 48.5714302062988 }, { "p": Vector3(130.3704, 50.19608, -382.4197), "r": 23.4825611114502 }, { "p": Vector3(414.8148, 50.19608, -385.5803), "r": 24.5991859436035 }, { "p": Vector3(271.8025, 50.19608, -80.59261), "r": 22.6700191497803 }]

func visual_circle():
	var cyl = CSGCylinder3D.new()
	cyl.radius = CircleZone.icr
	cyl.height = 50.0
	get_parent().add_child(cyl)
	cyl.global_position.x = CircleZone.icp.x
	cyl.global_position.z = CircleZone.icp.y
	cyl.sides = 128
	cyl.global_position.y = 50.0
	
func spawn_pois():
	for poi in pois:
		var cyl = CSGCylinder3D.new()
		cyl.radius = poi.r
		cyl.height = 50.0
		cyl.visible = false
		get_parent().add_child(cyl)
		cyl.global_position = poi.p
		cyl.add_to_group("loot")
		
func assign_squad(p, i):
	p.squad = i
	p.color = colors[i]
	p.on_assign()
	
func spawn():
	var player_scene = preload("res://player.tscn")
	for i in range(100):
		var p = player_scene.instantiate()
		p.pid = i
		get_parent().add_child(p)
		var idx = randi_range(0, $%NavigationRegion3D.navigation_mesh.get_polygon_count() - 1)
		var v = $%NavigationRegion3D.navigation_mesh.get_vertices()[$%NavigationRegion3D.navigation_mesh.get_polygon(idx)[0]]
		p.global_position = v
	
	var squad_id = 0
	var player_pool = get_tree().get_nodes_in_group("player")
	var leader
	
	while squad_id < 25:
		# find a leader
		for player in player_pool:
			if player.is_in_group("recruited"):
				continue
			leader = player
			assign_squad(leader, squad_id)
			break
		
		# recruit 3 closest neighbors
		for i in range(3):
			var min_dist = 10000000
			var min_player = null
			for player in player_pool:
				if player.is_in_group("recruited"):
					continue
				var dist = player.global_position.distance_to(leader.global_position)
				if dist < min_dist:
					min_dist = dist
					min_player = player
			assign_squad(min_player, squad_id)
		squad_id += 1

func pan_dist():
	return 512.0 / size
	
func _process(delta):
	if !current:
		return
	if !CircleZone.busy && !CircleZone.is_done_shrinking():
		var x = 0
		var y = 0
		if Input.is_action_pressed("ui_left"):
			CircleZone.icp.x += delta * 10.0
			x -= 1
		if Input.is_action_pressed("ui_right"):
			CircleZone.icp.x -= delta * 10.0
			x += 1
		if Input.is_action_pressed("ui_up"):
			CircleZone.icp.y += delta * 10.0
			y -= 1
		if Input.is_action_pressed("ui_down"):
			CircleZone.icp.y -= delta * 10.0
			y += 1
			
		if (x or y):
			if !$WhirSound.playing:
				$WhirSound.play()
		else:
			$WhirSound.stop()
			
func _physics_process(delta):
	if !current || sticky:
		return
	var mp = get_viewport().get_mouse_position()
	var from = project_ray_origin(mp)
	var to = from + project_ray_normal(mp) * 1000.0
	var query =  PhysicsRayQueryParameters3D.create(from, to, 4)
	query.collide_with_areas = true
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result && "collider" in result:
		var p = result.collider.get_parent()
		$%UI.set_player(p)
	else:
		$%UI.untrack()
#var poi_pending = null
#var poi = []

var dragging = false
var drag_anchor
var drag_pos
func _input(event):
	if !current:
		return
	if event.is_action_pressed("ui_accept"):
		if CircleZone.can_close():
			$ButtonSound.play()
			CircleZone.close_circle()
	if event is InputEventMouseMotion && dragging:
		var sc = 512.0 / size
		var bound = (512.0 - size) / 2.0
		global_position.x = (event.position.x - drag_anchor.x) / sc + drag_pos.x
		global_position.z = (event.position.y - drag_anchor.y) / sc + drag_pos.z
		global_position.x = min(max(global_position.x, 256.0 - bound), 256.0 + bound)
		global_position.z = min(max(global_position.z, -256.0 - bound), -256.0 + bound)
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = true
				drag_anchor = event.position
				drag_pos = global_position
#				if result && "position" in result:
##					poi_pending = result.position
##					return
#					for character in get_tree().get_nodes_in_group("player"):
#						character.plot_course(result.position)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if size <= 64.0:
					return
				if !$ZoomInSound.playing:
					$ZoomInSound.play()
				size = max(size / 2.0, 64.0)
				var from = project_ray_origin(event.position)
				var to = from + project_ray_normal(event.position) * 1000.0
				var query =  PhysicsRayQueryParameters3D.create(from, to)
				var result = get_world_3d().direct_space_state.intersect_ray(query)
				if result && "position" in result && !dragging:
					global_position.x = result.position.x
					global_position.z = result.position.z
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if size < 512.0:
					if !$ZoomOutSound.playing:
						$ZoomOutSound.play()
				size = min(size * 2, 512.0)
				if size >= 512.0:
					global_position.x = 256.0
					global_position.z = -256.0
					return
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging = false
			if drag_anchor.distance_to(event.position) < 5.0:
				# click, not drag (probably lol)
				var from = project_ray_origin(event.position)
				var to = from + project_ray_normal(event.position) * 1000.0
				var query =  PhysicsRayQueryParameters3D.create(from, to, 4)
				query.collide_with_areas = true
				var result = get_world_3d().direct_space_state.intersect_ray(query)
				if result && "position" in result:
					var p = result.collider.get_parent()
					$%UI.set_player(p)
					sticky = true
				else:
					$%UI.untrack()
					sticky = false
			# released
			pass
#		else:
#			if event.button_index == MOUSE_BUTTON_LEFT:
#				var from = project_ray_origin(event.position)
#				var to = from + project_ray_normal(event.position) * 1000.0
#				var query =  PhysicsRayQueryParameters3D.create(from, to)
#				query.collide_with_areas = true
#				var result = get_world_3d().direct_space_state.intersect_ray(query)
#				if result && "position" in result:
#					poi.push_back({ "p": poi_pending, "r": result.position.distance_to(poi_pending) })
