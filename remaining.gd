extends Label


var prev
# Called when the node enters the scene tree for the first time.
func _ready():
	prev = ceil(CircleZone.timer)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cur = ceil(CircleZone.timer)
	if cur < prev && cur < 4:
		if cur == 0:
			$DingSound.pitch_scale = 1.55
		else:
			$DingSound.pitch_scale = 1.0
		$DingSound.play()
			
	prev = cur
	var fstr="""BattleOS v20.17
====================================
Players remaining: {0}
Squads remaining: {1}
Zone shrinks in {2} seconds
===================================="""
	if CircleZone.is_done_shrinking():
		fstr="""BattleOS v20.17
====================================
Players remaining: {0}
Squads remaining: {1}
Zone will not shrink any further.
===================================="""
	if CircleZone.busy:
		fstr="""BattleOS v20.17
====================================
Players remaining: {0}
Squads remaining: {1}
Zone shrinking...
===================================="""
	if !CircleZone.started:
		fstr="""BattleOS v20.17
====================================
Initializing bootloader...
Pre-heating chicken dinner...
Awaiting players...
===================================="""
	text=fstr.format([get_tree().get_nodes_in_group("player").size(), CircleZone.squads_alive, ceil(CircleZone.timer)])

	pass
