extends Node

var objects = []
var factory = load("./factory.gd")

	
func spawnAll(parent = null):
	if parent == null:
		parent = get_tree().get_root()
	for x in objects:
		var newObject = factory.create(x["groups"], x["transform"])
		parent.add_child(newObject)
	pass

func collectAll(parent= null, groupName = "persistence"):
	if parent == null:
		parent = get_tree().get_root()
	var nodes = parent.get_nodes_in_group(groupName)
	for n in nodes :
		var obj = {
			"groups": n.get_groups(),
			"transform" : n.get_global_transform()
		}
		objects.push_back(obj)	
	pass
