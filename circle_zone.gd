extends Node


var ocr = null
var icr = null
var ocp = null
var icp = null


var usernames = [
		"badcop",
		"gamerpiejess",
		"brimonk",
		"hikokimari",
		"swagmaster96",
		"felix4",
		"coolguy1444",
		"BigFortniteGamer",
		"danthetoucan",
		"anon88",
		"futurepresident4",
		"oldtimer54",
		"cheeseeater50",
		"cowsarefriends",
		"MonsterCheef",
		"businessexpert19",
		"doglover777",
		"abstracttriangle0",
		"gamedeveloper40",
		"addicted_to_ribbit",
		"gravekeeper6",
		"grimraptor33",
		"easterbunny11",
		"gamergirl01",
		"oldwestern98",
		"PM_ME_PLSSSS",
		"foreveralone__",
		"yeetyeetyeeeeet",
		"chewbacca007",
		"jamesbond55",
		"secretagent_1",
		"iphoneuser55",
		"cheeeeesecakeeee",
		"pancakes4ever",
		"marshmallows5ever",
		"birdsarecool22",
		"disasterus959",
		"yesyesyesyesh",
		"cyal8ralig8r",
		"pingpongchamp0",
		"ProudDad16",
		"excited4pkc",
		"jdf_is_better",
		"i_love_jdf",
		"pkc_stan",
		"jdf_stan",
		"megamindbestmovie",
		"buzzlightyrjr",
		"CapnObvius",
		"MoustachedWar",
		"OxfordComma",
		"JDzX",
		"BereBery",
		"Dotso",
		"Laney03",
		"CentBox",
		"Gabler",
		"Golemri",
		"Linget",
		"Prattin",
		"SoccerLyfe",
		"TrackerRoz",
		"Boltex",
		"Crawlerildr",
		"Gemmagy",
		"Haymisab",
		"LummoAbove",
		"Revini",
		"Stegoty",
		"weeddi",
		"Briconia",
		"Dinged",
		"Godatro",
		"LawnExtra",
		"MessagesWitch",
		"Scannoyer",
		"TenPrecise",
		"GoodPlayer223",
		"Everma",
		"Lindebasi",
		"Plotiona",
		"Shardis",
		"TigerBoosh",
		"BanditFix",
		"Inextsoft55",
		"Medtershe",
		"RollXan",
		"Washton",
		"Amesiani",
		"BoostMura",
		"Insides",
		"NearlyPool97",
		"ScoobyWow",
		"Truestem",
		"Bracess",
		"LessChronos",
		"NeoRadiant",
		"UnderWa",
		"BristleKemp",
		"TheSnail2",
		"PapaHeadline",
		"RealMore",
		"SpunkyBroadway",
		"xVengeans",
		"Forumenti",
		"Nanosakim",
		"Studison",
		"Bentlor",
		"CowPow1",
		"BeefyCheesy",
		"Landerne",
		"Percsha",
		"Solidgene",
		"TacticAngles",
		"Wizewiz5",
		"Callarts",
		"Hondatash",
		"Lightshma",
		"Pinkin",
		"Spydersans",
		"Talenta",
		"UntamedLlama",
		"QuotePerson87",
		"Stonefire",
		"Biocalo",
		"Currica",
		"Borgizen",
		"Florrekko",
		"Lentiva",
		"MrWar",
		"TigerNees",
		"DragonQ",
		"Godanque",
		"Pongle557",
		"UpforceSign",
		"McNephew",
		"Pandee",
		"Venuest9",
		"SweetieDown",
		"TwinkleStarSprite",
		"TickleMeBatman",
		"Casualte42",
		"JoshXoo",
		"Postic",
		"NaanViolence09",
		"MotoHead",
		"InAMeeting",
		"playerunknown",
		"playerknown",
		"fortniteisbetter",
		"CHUGJUG",
		"wherewedroppin",
		"godotuser"
]

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
signal killed(who, by)
	
var timer

func _process(delta):
	if busy || is_done_shrinking():
		return
	timer -= delta
	timer = max(0.0, timer)
	if timer == 0.0:
		close_circle()
		
func reset():
	usernames.shuffle()
	timer = 20.0
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

func is_done_shrinking():
	return size > sizes.size()
	
func new_inner():
	if size >= sizes.size():
		size += 1
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
	timer = 20.0
	# todo: smaller inner
