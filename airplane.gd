extends Node3D


var started = false
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(20.0).timeout
	if !is_instance_valid(self):
		return
	if !started:
		$%GameCam.start_the_game()
		started = true
		queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if !started:
			started = true
			$%GameCam.start_the_game()
			queue_free()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += global_transform.basis.z * delta * 250.0
