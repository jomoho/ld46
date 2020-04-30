extends Spatial


const DAY_TIME = 30.0
const TICK_INTERVAL = 2

var timeAlive = 0;
var tickCounter = 0;

export(Gradient) var lightGradient
export(Vector3) var lightEulerStart
export(Vector3) var lightEulerEnd
var lightStart
var lightEnd

func _process(_delta):
	timeAlive += _delta
	tickCounter += _delta
	if tickCounter >= TICK_INTERVAL:
		tickCounter = 0;
		tick()
		
	pass

func _ready():
	lightStart = Transform(Quat(lightEulerStart))
	lightEnd = Transform(Quat(lightEulerEnd))
	pass

func tick():
	print("tick day %s" % name);
	$DirectionalLight.transform = lightStart.interpolate_with(lightEnd, dayProgress())
	if timeAlive > DAY_TIME:
		day_over()
	pass

func dayProgress():
	return timeAlive/DAY_TIME

func day_over():
	print("Day over")
	get_node("/root/globals").days += 1
	get_tree().change_scene("res://scenes/night_round/night_round.tscn")
	pass

	pass
