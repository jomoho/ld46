extends "carry.gd"


func _on_Area_body_entered(body):
	print("poo entered")
	print(body.name)
	if(body.is_in_group("player")):
		body.enter_poo(self)	
	
	if(body.is_in_group("dungheap")):
		queue_free()
	pass
	
func _on_Area_body_exited(body):
	body.exit_area(self)
	pass
