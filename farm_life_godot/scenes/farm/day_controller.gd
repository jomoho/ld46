extends Spatial


const DAY_TIME = 240.0
const TICK_INTERVAL = 2

var timeAlive = 0;
var tickCounter = 0;

export(NodePath) var playerPath
export(Gradient) var lightGradient
export(Gradient) var skyGradient
export(Vector3) var lightEulerStart
export(Vector3) var lightEulerMiddle
export(Vector3) var lightEulerEnd

var lightStart
var lightMiddle
var lightEnd
var player

func _ready():
	lightStart = Transform(Quat(lightEulerStart))
	lightMiddle = Transform(Quat(lightEulerMiddle))
	lightEnd = Transform(Quat(lightEulerEnd))
	player = get_node(playerPath)
	pass

func _process(_delta):
	timeAlive += _delta
	tickCounter += _delta
	if tickCounter >= TICK_INTERVAL:
		tickCounter = 0;
		tick()
	setLight()
	transform.origin = player.transform.origin
	pass

func tick():
	print("tick day timeAlive: %f progress: %f" % [timeAlive, dayProgress()]);
	print($DirectionalLight.transform.basis.get_euler())
	
	if timeAlive > DAY_TIME:
		day_over()
	pass

func dayProgress():
	return timeAlive/DAY_TIME
	
func setLight():
	var prg = dayProgress()
	var euler
	if prg < 0.5:
		euler = lightEulerStart.linear_interpolate(lightEulerMiddle, prg * 2.0)
	else:
		euler = lightEulerMiddle.linear_interpolate(lightEulerEnd,( prg-0.5) * 2.0)
	euler = Vector3(deg2rad(euler.x), deg2rad(euler.y),deg2rad(euler.z))
	$DirectionalLight.transform = Transform(Quat(euler))
	
	$DirectionalLight.light_color = lightGradient.interpolate(dayProgress())
	setSunColor(lightGradient.interpolate(dayProgress()))
	VisualServer.set_default_clear_color( lightGradient.interpolate(dayProgress()))
	pass
func setSunColor(color):
	$DirectionalLight/MeshInstance.material_override.albedo_color = color
	var material= $DirectionalLight/MeshInstance.get_surface_material(0)
	#material.albedo_color = color
	#$DirectionalLight/MeshInstance.set_surface_material(0, material)
	pass

func day_over():
	print("Day over")
	get_node("/root/globals").days += 1
	get_tree().change_scene("res://scenes/night_round/night_round.tscn")
	pass

	pass
