extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	text=fstr.format([get_tree().get_nodes_in_group("player").size(), CircleZone.squads_alive, ceil(CircleZone.timer)])

	pass
