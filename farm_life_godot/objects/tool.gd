# TOOL
extends "carry.gd"

func _on_Area_body_entered(body):
	print("%s entered" % name)
	print(body.name)
	if body.is_in_group("player"):
		body.enter_tool(self)
	pass 


func _on_Area_body_exited(body):
	body.exit_area(self)
	pass 

func make_text():
	return name
