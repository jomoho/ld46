extends Spatial


const DAY_TIME = 240.0
const TICK_INTERVAL = 2

var timeAlive = 0;
var tickCounter = 0;

export(NodePath) var playerPath
export(Gradient) var lightGradient
export(Gradient) var skyGradient
export(Gradient) var ambientGradient

export(Curve) var sunSizeCurve

export(Vector3) var lightEulerStart
export(Vector3) var lightEulerMiddle
export(Vector3) var lightEulerEnd

onready var lightStart = Transform(Quat(lightEulerStart))
onready var lightMiddle = Transform(Quat(lightEulerMiddle))
onready var lightEnd = Transform(Quat(lightEulerEnd))
onready var player = get_node(playerPath)
onready var cam = get_tree().get_root().get_camera()
onready var environment = $WorldEnvironment.get_environment()
onready var sunIdentity = $DirectionalLight/MeshInstance.transform

func _ready():
	environment.fog_enabled = true;
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
	var skyColor =  skyGradient.interpolate(prg)
	var sunColor =  lightGradient.interpolate(prg)
	var ambientColor =  ambientGradient.interpolate(prg)
	setSunColor(sunColor)
	VisualServer.set_default_clear_color(skyColor)
	$WorldEnvironment.get_environment().ambient_light_color = ambientColor
	
	var sunSize = sunSizeCurve.interpolate(prg)
	#print(sunSize)
	$DirectionalLight/MeshInstance.transform.basis = sunIdentity.scaled(Vector3(sunSize,sunSize,sunSize)).basis
	pass
func setSunColor(color):
	$WorldEnvironment.get_environment().fog_sun_color = color
	$DirectionalLight.light_color = color
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
