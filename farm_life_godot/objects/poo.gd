extends "labeled _rigidbody.gd"

var destroyed = false;

func _on_Area_body_entered(body):
	print("poo entered")
	print(body.name)
	if(body.is_in_group("player")):
		body.enter_poo(self)	
	
	if(body.is_in_group("dungheap")):
		destroy_poo()
	pass
	
func _on_Area_body_exited(body):
	body.exit_area(self)
	if(body.is_in_group("dungheap")):
		destroy_poo()
	pass
	
func destroy_poo():
	if  not destroyed:
		destroyed = true
		$sfxDelete.play()
		$mesh.hide()
		$poo_explosion.emitting = true;
		yield(get_tree().create_timer(0.5), "timeout")
		queue_free()

