extends Node3D


var started = false
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.0).timeout
	$CRTSound.play()
	await $CRTSound.finished
	$AudioStreamPlayer.play()
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
			
var fade = -2.6
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fade += delta * 2.0
	RenderingServer.global_shader_parameter_set("crt_on", max(0.0, min(1.0, fade)))
	global_position += global_transform.basis.z * delta * 250.0
