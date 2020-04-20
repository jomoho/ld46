extends Spatial

export var game_over = false

func _ready():
	if game_over:
		load_stats()
	pass 

func load_stats():
	$Control.get_node("stats").set_text( "Stats: %s" % get_node("/root/globals").get_stats())
	pass

func _on_StartButton_pressed():
	print("START")
	get_tree().change_scene("res://scenes/farm/farm_level.tscn")
	pass 
