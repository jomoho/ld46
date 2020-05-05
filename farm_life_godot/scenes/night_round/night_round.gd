extends Spatial

var days = 0;

var selectedItem = -1

var items = ["gras", "milk"]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	days = get_node("/root/globals").days
	$Control/TabContainer/Status/title.set_text("End of Day #%d" % days)
	for x in items:
		$Control/TabContainer/Sell/SellItemsList.add_item(x)	
	load_stats()
	$Control/TabContainer/Sell/VBoxContainer/SellItemButton.set_disabled(true)
	pass 

func load_stats():
	$Control/TabContainer/Status/stats.set_text( "Stats: %s" % get_node("/root/globals").get_stats())
	pass

func _on_StartButton_pressed():
	print("START")
	get_tree().change_scene("res://scenes/farm/farm_level.tscn")
	pass 

func _on_SellItemButton_pressed():
	print("sell item")
	if selectedItem >= 0:
		$Control/TabContainer/Sell/SellItemsList.remove_item(selectedItem)
		items.remove(selectedItem)
		selectedItem = -1
		$Control/TabContainer/Sell/VBoxContainer/SellItemButton.set_disabled(true)
	pass

func _on_SellItemsList_item_selected(index):
	selectedItem = index
	$Control/TabContainer/Sell/VBoxContainer/SellItemButton.set_disabled(false)
	showSellDescription(index)
	pass

func showSellDescription(index):
	$Control/TabContainer/Sell/VBoxContainer/DescriptionLabel.set_text(items[index])
	pass
