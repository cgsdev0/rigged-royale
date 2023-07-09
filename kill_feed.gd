extends Label



var lines = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	CircleZone.connect("killed", on_kill)
	pass # Replace with function body.

func on_kill(who, by):
	$KillSound.play()
	lines += 1
	if lines > 10:
		lines_skipped += 1
	var by_text = "the blue"
	if by >= 0:
		by_text = CircleZone.usernames[by]
	text += CircleZone.usernames[who] + " was killed by " + by_text + "\n"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
