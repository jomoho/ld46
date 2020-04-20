extends "carry.gd"

var transportAnchors = []
var stack = []
func _ready():
	transportAnchors.push_back(get_node("transportAnchor1"))
	transportAnchors.push_back(get_node("transportAnchor2"))
	transportAnchors.push_back(get_node("transportAnchor3"))
	transportAnchors.push_back(get_node("transportAnchor4"))
	pass

func load_stack(body):
	if stack.size()< 4:
		stack.push_back(body)
		body.transporter = self
		body.isCarried=true

func unload_stack(player):
	if stack.size() > 0:
		var x = stack.pop_back()
		player.pick_to_carry(x)
		
	pass
	
func unload_from_stack(item):
	if stack.size() > 0:		
		for i in range(stack.size()):
			if stack[i].get_instance_id() == item.get_instance_id():
				stack.remove(i)
				i +=1
				item.drop()	
		
	pass
	
func is_loaded():
	return stack.size() >0

func _process(_delta):
	for i in range(stack.size()):
		stack[i].set_transform(transportAnchors[i].get_global_transform())
	pass


func _on_Area_body_entered(body):
	print("wheelbarrow entered")
	print(body.name)
	body.enter_wheelbarrow(self)
	pass
	
func _on_Area_body_exited(body):
	body.exit_area(self)
	pass
