extends Node2D

export var game_over = false

func _ready():
	if game_over:
		load_stats()
	pass 

func load_stats():
	$stats.set_text( "Stats: %s" % get_node("/root/globals").get_stats())
	pass

func _on_StartButton_pressed():
	get_tree().change_scene("res://scenes/farm/farm_level.tscn")
	pass 
