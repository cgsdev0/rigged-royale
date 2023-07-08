extends Node3D

var color = Color.HOT_PINK
var squad = 0

enum State {
	IDLE,
	REGROUPING
}
var state = State.IDLE

var regroup_timer = 0.0

# stats
var health = 100.0
var loot = 0.0

# traits
var regroup_timer_max
var min_peer_dist

func roll_traits():
	regroup_timer_max = randf_range(4.3, 6.2)
	min_peer_dist = randf_range(2.0, 10.0)
	
func on_assign():
	roll_traits()
	$CSGSphere3D.material.albedo_color = color
	add_to_group("recruited")
	add_to_group("squad" + str(squad))

func plot_course(target):
	if !target:
		return
	$NavigationAgent3D.target_position = target
	
func pick_new_state():
	if regroup_timer > regroup_timer_max && state == State.REGROUPING:
		return State.IDLE
	if min_peer_distance() > min_peer_dist:
		return State.REGROUPING
	return State.IDLE
	
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
	
	# check if we should change state
	state = pick_new_state()
	
	match state:
		State.REGROUPING:
			regroup_timer += delta
		
	# do things on transitions
	match [prev_state, state]:
		[State.IDLE, State.REGROUPING]:
			regroup_timer = 0.0
			plot_course(find_squad_center())
			
		
	if state == State.IDLE || $NavigationAgent3D.is_navigation_finished():
		state = State.IDLE
		return
	
	var next = $NavigationAgent3D.get_next_path_position()
	if next:
		velocity = (next - global_position).normalized() * SPEED

	if global_position.y < 52:
		velocity *= 0.4
		
	global_position += velocity * delta
