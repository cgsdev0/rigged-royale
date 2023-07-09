extends Node


var ocr = null
var icr = null
var ocp = null
var icp = null


var sizes = [
	400.0,
	300.0,
	200.0,
	100.0,
	40.0
]

var squads = []
var squads_alive = 25
var size = 0

func kill(squad):
	squads[squad] -= 1
	if squads[squad] == 0:
		squads_alive -= 1
	
	if squads_alive < 2:
		self.emit_signal("winner_winner")

signal winner_winner
	
func reset():
	size = 0
	new_inner()
	ocr = 400.0
	ocp = icp
	squads = []
	squads_alive = 25
	for i in range(25):
		squads.push_back(4)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	
func new_inner():
	if size >= sizes.size():
		return
		
	var r = sizes[size] / 2.0
	if icp == null:
		icp = Vector2(randf_range(r, 512 - r), -randf_range(r, 512 - r))
	icr = r
	size += 1

var busy = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func close_circle():
	if busy:
		return
	busy = true
	var t = get_tree().create_tween()
	t.set_parallel()
	t.tween_property(self, "ocr", icr, 20.0)
	t.tween_property(self, "ocp", icp, 20.0)
	await t.finished
	new_inner()
	busy = false
	# todo: smaller inner
