# GRAS
extends  "./labeled _rigidbody.gd"

func _on_Area_body_entered(body):
	print("gras entered")
	print(body.name)
	body.enter_gras(self)
	pass # Replace with function body.
	
func _on_Area_body_exited(body):
	body.exit_area(self)
	pass


