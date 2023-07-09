extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	CircleZone.connect("winner_winner", on_win)


func on_win():
	visible = true
	$AnimationPlayer.play("flash")
