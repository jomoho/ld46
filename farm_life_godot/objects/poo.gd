extends RigidBody

# stuff
var label
var labelAnchor
var cam

var timeAlive = 0;

func _process(_delta):
	timeAlive += _delta
	## adjust label position
	var pos = labelAnchor.get_global_transform().origin;
	var screenPos = cam.unproject_position(pos);
	label.set_position(screenPos);

# Called when the node enters the scene tree for the first time.
func _ready():
	cam = get_tree().get_root().get_camera()
	label = get_node("Label")
	labelAnchor = get_node("LabelAnchor")
	pass


func _on_Area_body_entered(body):
	print("poo entered")
	print(body.name)
	body.enter_poo(self)
	pass
	
func _on_Area_body_exited(body):
	body.exit_area(self)
	pass
