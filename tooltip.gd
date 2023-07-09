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
	$%Heal.connect("pressed", heal)
	$%Sniper.connect("pressed", sniper)
	pass # Replace with function body.

func heal():
	$%Heal/Sound.play()
	player.health = 100.0

func sniper():
	$%Sniper/Sound.play()
	player.has_sniper = true
	player.loot = player.loot_goblin # max loot
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !player || !visible:
		return
	$%Heal.disabled = player.dead
	$%Sniper.disabled = player.dead || player.has_sniper
	$%Name.text = CircleZone.usernames[player.pid]
	$%Kills.text = str(player.kills) + " Kills"
	$%HealthBar.value = player.health
	pass
