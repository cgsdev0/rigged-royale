extends Control

var player

func set_player(p):
	untrack()
	player = p
	player.tracked = true
	visible = true
	
func untrack():
	visible = false
	if player:
		player.tracked = false
		player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !player || !visible:
		return
	$%Name.text = CircleZone.usernames[player.pid]
	$%Kills.text = str(player.kills) + " Kills"
	$%HealthBar.value = player.health
	pass
