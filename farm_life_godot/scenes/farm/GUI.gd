extends Control

func _ready():
	pass

func _process(_delta):
	var poo = get_tree().get_nodes_in_group("poo");
	var level = get_tree().get_root().get_node("farm_level")
	var txt = "poo: %d familyHealth: %d/100 reserve: %d" % [poo.size(), level.familyHealth, level.feedReserve*100 ]
	$status.set_text(txt)


