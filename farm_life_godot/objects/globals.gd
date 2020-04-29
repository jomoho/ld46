extends Node

var pooCleaned = 0
var familyFed = 0
var cowFed = 0
var cowMilked = 0
var grasCut = 0

var timeAlive = 0

func _ready():
	pass

func reset():
	pooCleaned = 0
	familyFed = 0
	cowFed = 0
	cowMilked = 0
	grasCut = 0
	
	timeAlive = 0
	pass

func get_stats():
	return "Kept it alive: %2.2f seconds \ngras cut: %d cows milked: %d Cows fed: %d \npoo cleaned: %d family fed: %d" % [timeAlive, grasCut, cowMilked, cowFed,pooCleaned, familyFed]
	
