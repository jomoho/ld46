extends Spatial

const MILK_FEED_TIME = 30.0
const TICK_INTERVAL = 2
const MAX_FAMILY_HEALTH = 100
var familyHealth = MAX_FAMILY_HEALTH

var hungry = true

var timeAlive = 0;
var tickCounter = 0;
var feedingCounter = MILK_FEED_TIME/2;

var pooScene
var milkcanScene
var feedReserve
var player

func _process(_delta):
	timeAlive += _delta
	tickCounter += _delta
	feedingCounter += _delta
	if tickCounter >= TICK_INTERVAL:
		tickCounter = 0;
		tick()
		
	if(Input.is_action_pressed("pause")):
		_on_pause_button_pressed()
	
	hungry = true
	if feedingCounter < MILK_FEED_TIME and feedingCounter > 0:
		hungry =false
		feedReserve = 1.0 - (feedingCounter/MILK_FEED_TIME)
	pass

func _ready():	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player = get_node("Player")
	$pause_popup.hide()
	$pause_popup.pause_mode = Node.PAUSE_MODE_PROCESS
	pass

func tick():
	print("tick family %s" % name);
	if hungry:
		familyHealth -= 1
	else:
		familyHealth += 2

	familyHealth = min(familyHealth, MAX_FAMILY_HEALTH)

	if familyHealth <= 0:
		game_over()
	pass

func _on_dungheap_body_entered(body):
	if body.is_in_group("poo"):
		if body.isCarried:
			body.transporter_unload_stack()
		get_node("/root/globals").pooCleaned += 1
		body.destroy_poo()
		yield(get_tree().create_timer(0.5), "timeout")
		player.label.set_text("You cleaned up the poo!")
	pass

func feed_family():
	feedingCounter = 0
	print("feed family")
	player.get_node("sfxFeeding").play()
	get_node("/root/globals").familyFed += 1
	pass

func game_over():
	print("game over!")
	get_node("/root/globals").timeAlive = timeAlive
	get_tree().change_scene("res://scenes/game_over/game_over.tscn")
	pass


func _on_kitchenArea_body_entered(body):
	if body.is_in_group("milkcan"):
		feed_family()
		if body.isCarried:
			body.transporter_unload_stack()
		body.queue_free();

		yield(get_tree().create_timer(0.3), "timeout")
		player.label.set_text("You fed the family!")
	pass
	
func _on_pause_button_pressed():	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$pause_popup/ColorRect/status.set_text("Stats: %s" % get_node("/root/globals").get_stats())
	$pause_popup.show()
	
	pass


func _on_ContinueButton_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$pause_popup.hide()
	get_tree().paused = false
	pass # Replace with function body.


func _on_ExitToMenuButton_pressed():
	get_tree().change_scene("res://scenes/start/start_menu.tscn")
	pass # Replace with function body.
