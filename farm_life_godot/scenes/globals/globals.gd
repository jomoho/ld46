extends Node

var pooCleaned = 0
var familyFed = 0
var cowFed = 0
var cowMilked = 0
var grasCut = 0
var days = 0

var gold = 0
var timeAlive = 0

var settings = null

func _ready():
	var S = load("res://scenes/globals/settings.gd")
	settings = S.new()
	#settings.load()
	pass

func reset():
	pooCleaned = 0
	familyFed = 0
	cowFed = 0
	cowMilked = 0
	grasCut = 0
	
	timeAlive = 0
	days = 0
	pass
	
func _process(_delta):
	
	if(Input.is_action_pressed("debug_on")):
		settings.showLabels = true
		print("debug_on")
	if(Input.is_action_pressed("debug_off")):
		print("debug_off")
		settings.showLabels = false
	pass

func get_stats():
	return "Kept it alive: %2.2f seconds \ngras cut: %d cows milked: %d Cows fed: %d \npoo cleaned: %d family fed: %d" % [timeAlive, grasCut, cowMilked, cowFed,pooCleaned, familyFed]
	
