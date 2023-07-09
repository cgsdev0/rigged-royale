extends Node3D

var color = Color.HOT_PINK
var squad = 0
var pid = 0

enum State {
	IDLE,
	REGROUPING,
	LOOTING,
	ENGAGING,
	FLEEING,
	CIRCLE
}
var state = State.IDLE

var debouncer = 0.0

var scan_angle = 0

# stats
var health = 100.0
var loot = 0.0

# traits
var regroup_timer_max
var min_peer_dist
var loot_goblin
var loot_speed
var groupiness
var greed
var circle_buffer
var innate_skill
var loot_rate

func fire_bullet(dist):
	if loot > 0.1:
		loot -= 0.01
	else:
		return false
	var roll = randf_range(0.0, 100.0)
	return roll < innate_skill * 0.1 + loot * 0.2 - dist / 3.0
	
func roll_traits():
	regroup_timer_max = randf_range(4.3, 6.2)
	min_peer_dist = randf_range(2.0, 10.0)
	loot_goblin = randf_range(30.0, 90.0)
	loot_speed = randf_range(0.8, 1.2)
	greed = randf_range(0.3, 0.8)
	groupiness = randf_range(0.3, 0.6)
	circle_buffer = randf_range(0.5, 4.0)
	innate_skill = randf_range(35.0, 65.0)
	loot_rate = randf_range(0.1, 0.25)
	
func on_assign():
	roll_traits()
	$CSGSphere3D.material.albedo_color = color
	add_to_group("recruited")
	add_to_group("squad" + str(squad))

func plot_course(target):
	if !target:
		return
	if typeof(target) == TYPE_VECTOR2:
		var from = Vector3(target.x, 1000, target.y)
		var to = Vector3(target.x, -1000, target.y)
		var query =  PhysicsRayQueryParameters3D.create(from, to)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if "position" in result:
			target = result.position
		else:
			print("BAD BAD BAD")
			return
			
	# reject targets outside the wall
	var txy = Vector2(target.x, target.z)
	if txy.distance_to(CircleZone.ocp) >= CircleZone.ocr:
		print("Agent ", pid, " is dumb af")
		return

	$NavigationAgent3D.target_position = target
	
func pick_new_state():
	if debouncer <= regroup_timer_max && state != State.IDLE:
		return state
	debouncer = 0.0
		
	var xy = Vector2(global_position.x, global_position.z)
	
	var desires = []
	# calculate desires
	var md = min_peer_distance()
	if md > min_peer_dist:
		desires.push_back([min(md / min_peer_dist * groupiness, 0.5), State.REGROUPING])
	
	if loot < loot_goblin:
		desires.push_back([min((loot_goblin - loot) / loot_goblin * greed, 1.0), State.LOOTING])
	
	var circle_desire = (xy.distance_to(CircleZone.ocp) - CircleZone.ocr + circle_buffer) * 10000.0
	if CircleZone.busy:
		circle_desire = (xy.distance_to(CircleZone.icp) - CircleZone.icr + circle_buffer) * 10000.0
	if circle_desire > 0.0:
		desires.push_back([circle_desire, State.CIRCLE])
	# choose a desire
	var max = 0
	var chosen = State.IDLE
	for desire in desires:
		if desire[0] > max:
			max = desire[0]
			chosen = desire[1]
	
	return chosen
	
func min_peer_distance():
	var peers = get_tree().get_nodes_in_group("squad" + str(squad))
	var peers_counted = 0
	var min = 1000000.0
	for peer in peers:
		if peer.get_instance_id() == get_instance_id():
			continue
		peers_counted += 1
		var d = peer.global_position.distance_to(global_position)
		if d < min:
			min = d
	
	if peers_counted == 0:
		return 0
	return min

func find_nearby_loot():
	var min = 1000000.0
	var target = null
	for l in get_tree().get_nodes_in_group("loot"):
		if !is_instance_valid(l):
			continue
		var lxy = Vector2(l.global_position.x, l.global_position.z)
		# ignore loot outside the circle
		if lxy.distance_to(CircleZone.ocp) >= CircleZone.ocr:
			l.queue_free()
			print("FREEING")
			continue
		var d = l.global_position.distance_to(global_position) - l.radius
		if d < min:
			min = d
			target = l
	
	if !target:
		return target
	var r = randf_range(0.0, target.radius)
	var theta = randf_range(0.0, 2 * PI)
	return target.global_position + Vector3(cos(theta) * r, 0.0, sin(theta) * r)
	
func find_squad_center():
	var peers = get_tree().get_nodes_in_group("squad" + str(squad))
	var peers_counted = 0
	var avg = Vector3.ZERO
	for peer in peers:
		if peer.get_instance_id() == get_instance_id():
			continue
		peers_counted += 1
		avg += peer.global_position
	
	if peers_counted == 0:
		return null
	return avg / peers_counted
	
func within_loot_area():
	var xy = Vector2(global_position.x, global_position.z)
	for l in get_tree().get_nodes_in_group("loot"):
		var lxy = Vector2(l.global_position.x, global_position.z)
		if xy.distance_squared_to(lxy) <= l.radius * l.radius:
			return true
	return false
	
func _physics_process(delta):
	if global_position.x > 512.0:
		print("HELP I AM LOST")
	if global_position.x < 0:
		print("HELP I AM LOST")
	if global_position.z < -512.0:
		print("HELP I AM LOST")
	if global_position.z > 0:
		print("HELP I AM LOST")
	var SPEED = 2
	var velocity = Vector3.ZERO
	
	var prev_state = state
	

	var xy = Vector2(global_position.x, global_position.z)
	var outside_wall = xy.distance_to(CircleZone.ocp) > CircleZone.ocr
	if outside_wall:
		take_damage(delta * CircleZone.size, -1) 
	
	# check if we should change state
	state = pick_new_state()
	
	debouncer += delta
		
	# do things every tick
	match state:
		State.LOOTING:
			if within_loot_area():
				loot = min(loot + delta * loot_rate, 100.0)
		
	$CSGSphere3D2.visible = outside_wall
	# do things on transitions
	if state != prev_state:
		debouncer = 0.0
		match state:
			State.REGROUPING:
				plot_course(find_squad_center())
			State.LOOTING:
				# print("Agent ", pid, " would like to loot")
				plot_course(find_nearby_loot())
			State.CIRCLE:
				plot_course(CircleZone.ocp)
			
	
	# sweep the horizons
	scan_angle = (scan_angle + 1) % 16
	for i in range(-4, 4):
		var from = global_position
		var to = (-global_transform.basis.z).normalized().rotated(Vector3.UP, (scan_angle - 8) / 8.0 * PI / 2.0) + Vector3(0, i / 40.0, 0)
		to = global_position + to.normalized() * 4.0 * (loot + 0.2)
		var query =  PhysicsRayQueryParameters3D.create(from, to, 4 | 2, [$RigidBody3D.get_rid()])
		query.collide_with_areas = true
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if "position" in result:
			if result.collider.collision_layer == 2:
				continue
			var who = result.collider.get_parent()
			if who.squad != squad:
				var shot_dist = who.global_position.distance_to(global_position)
				if fire_bullet(shot_dist):
					loot = min(loot + who.take_damage((loot / 2.0 + 0.5) * 10.0, self.pid), 100.0)
					var cyl = CSGCylinder3D.new()
					cyl.radius = 0.5
					get_parent().add_child(cyl)
					cyl.global_position = (who.global_position + global_position) / 2.0
					cyl.height = shot_dist
					cyl.look_at(who.global_position)
					cyl.material = preload("res://materials/tracer.tres")
					cyl.rotate(cyl.global_transform.basis.x, PI / 2.0)
				break
		
		
		
	if state == State.IDLE || $NavigationAgent3D.is_navigation_finished():
		state = State.IDLE
		return
	
	var next = $NavigationAgent3D.get_next_path_position()
	if next:
		velocity = (next - global_position).normalized() * SPEED

	look_at(global_position + velocity)
	if global_position.y < 52:
		velocity *= 0.4
		
	global_position += velocity * delta

func take_damage(how_much, by):
	#print(pid, " TOOK ", how_much, " DAMAGE")
	health -= how_much
	if health <= 0.0:
		CircleZone.kill(squad)
		CircleZone.emit_signal("killed", self.pid, by)
		queue_free()
		return loot / 2.0
	return 0.0
