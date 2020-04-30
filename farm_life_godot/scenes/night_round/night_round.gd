extends Spatial

var days = 0;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	days = get_node("/root/globals").days
	$Control.get_node("title").set_text("End of Day #%d" % days)
	load_stats()
	pass 

func load_stats():
	$Control.get_node("stats").set_text( "Stats: %s" % get_node("/root/globals").get_stats())
	pass

func _on_StartButton_pressed():
	print("START")
	get_tree().change_scene("res://scenes/farm/farm_level.tscn")
	pass 
