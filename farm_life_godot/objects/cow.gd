extends "carry.gd"

const POO_INTERVAL = 20
const TICK_INTERVAL = 2

var foodQueue = 0
var hungry = true
var milkAvailable = 0
var pooTimer = 0
var health = 100
var tickCounter = 0;

var pooScene
var milkcanScene
var deadCowSene

func _process(_delta):
	tickCounter += _delta
	if tickCounter >= TICK_INTERVAL:
		tickCounter = 0;
		tick()
	hungry = true
	if foodQueue > 0:
		hungry = false
		pooTimer += _delta
		if pooTimer > POO_INTERVAL:
			make_poo()
			milkAvailable = true
			pooTimer = 0;
			foodQueue -=1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pooScene = load("res://objects/poo.tscn")
	milkcanScene = load("res://objects/milkcan.tscn")
	deadCowSene = load("res://objects/milkcan.tscn")
	pass

func tick():
	print("tick cow %s" % name);
	if hungry:
		health -= 1
	else:
		health += 2
	var pooCount = get_tree().get_nodes_in_group("poo").size()
	health -= floor(pooCount * 0.5)
	health = min(health, 100)
	if health < 0:
		die();
	pass

func make_poo():
	print("poooooooooooooo")	
	$sfxPoo.play()
	
	var poo = pooScene.instance()
	poo.set_global_transform($poo_spawn.get_global_transform())
	get_tree().get_root().add_child(poo)
	pass

func enter_gras(body):
	if hungry:
		foodQueue += 1
		get_node("/root/globals").cowFed += 1
		$sfxEat.play()
		body.queue_free()
	pass

func has_milk():
	return milkAvailable

func is_hungry():
	return hungry

func hungryText():
	if hungry:
		return "is hungry"
	else:
		return "is digesting... %d/10" % ((pooTimer/POO_INTERVAL)*10)
	pass
	
func make_text():
	var status = hungryText()
	if milkAvailable:
		status = "has milk"
		if hungry:
			status = "%s and is hungry" % status
	return "%s %s h:%d/100" % [name, status, health]
	pass
	
func die():
	print("cow die")
	$sfxDie.play()

	var milk = milkcanScene.instance()
	milk.set_global_transform(get_global_transform())
	get_tree().get_root().add_child(milk)
	
	yield(get_tree().create_timer(2), "timeout")
	queue_free();
	pass

func exit_area(body):
	pass

func milk_action(body):
	if has_milk():
		print("milk_action")
		milkAvailable = false
		$sfxMilk.play()
		var milk = milkcanScene.instance()
		milk.set_global_transform($milk_spawn.get_global_transform())
		get_tree().get_root().add_child(milk)
		
		pass


func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.enter_cow(self)
	pass
	pass # Replace with function body.
