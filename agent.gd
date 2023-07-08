extends CharacterBody3D

var SPEED = 30

func plot_course(target):
	$NavigationAgent3D.target_position = target
	
func _physics_process(delta):
	velocity = Vector3.ZERO
	
	if $NavigationAgent3D.is_navigation_finished():
		return

	var next = $NavigationAgent3D.get_next_path_position()
	if next:
		velocity = (next - global_position).normalized() * SPEED

	if global_position.y < 31.2:
		velocity *= 0.4
		
	move_and_slide()
