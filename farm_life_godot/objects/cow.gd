extends "carry.gd"

const POO_INTERVAL = 20
const HUNGER_INTERVAL = 40
const TICK_INTERVAL = 2

var foodQueue = 0
var hungry = true
var milkAvailable = 1
var pooTimer = 0
var hungerTimer = 0
var health = 100
var tickCounter = 0;

export(NodePath)  var animTreePath
var animTree

var pooScene
var milkcanScene
var deadCowSene

func _process(_delta):
	tickCounter += _delta
	hungerTimer += _delta
	if tickCounter >= TICK_INTERVAL:
		tickCounter = 0;
		tick()	
	if foodQueue > 0:
		hungerTimer = 0
		pooTimer += _delta
		if pooTimer > POO_INTERVAL:
			make_poo()
			milkAvailable = true
			pooTimer = 0;
			foodQueue -=1;
	hungry = false;
	if hungerTimer > HUNGER_INTERVAL:
		hungry = true

# Called when the node enters the scene tree for the first time.
func _ready():	
	animTree = get_node(animTreePath)	
	pooScene = load("res://objects/poo.tscn")
	milkcanScene = load("res://objects/milkcan.tscn")
	deadCowSene = load("res://objects/milkcan.tscn")
	pass

func tick():
	#print("tick cow %s" % name);
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
	print("%s : poooooooooooooo" % name)	
	$sfxPoo.play()
	
	var poo = pooScene.instance()
	poo.set_global_transform($poo_spawn.get_global_transform())
	
	animTree.set("parameters/poo/active", true)
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().get_root().add_child(poo)
	pass

func enter_gras(body):
	if pooTimer < POO_INTERVAL:
		foodQueue += 1
		health += 50
		get_node("/root/globals").cowFed += 1
		$sfxEat.play()
		body.queue_free()
		animTree.set("parameters/eat/active", true)
		yield(get_tree().create_timer(3), "timeout")
		animTree.set("parameters/eat/active", false)
	pass

func has_milk():
	return milkAvailable

func is_hungry():
	return hungry
	
func is_digesting():
	return foodQueue > 0

func hungry_text():
	if hungry:
		return "is hungry"
	elif is_digesting():
		return "is digesting... %d/10" % ((pooTimer/POO_INTERVAL)*10)
	else:
		return "is statisfied.. %d" % (100-((hungerTimer/HUNGER_INTERVAL)*100))
	pass
	
func make_text():
	var status = hungry_text()
	if milkAvailable:
		status = "has milk and %s " % status;
	return "%s %s \nh:%d/100" % [name, status, health]
	pass
	
func die():
	print("cow die")
	$sfxDie.play()

	var milk = milkcanScene.instance()
	milk.set_global_transform(get_global_transform())
	get_tree().get_root().add_child(milk)
	
	animTree.set("parameters/die/active", true)
	yield(get_tree().create_timer(1), "timeout")
	queue_free();
	pass

func exit_area(body):
	pass

func milk_action(body):
	if has_milk():
		print("milk_action")
		#TODO player callback
		milkAvailable = false		
		get_node("/root/globals").cowMilked += 1
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


func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		body.exit_area(self)
	pass
