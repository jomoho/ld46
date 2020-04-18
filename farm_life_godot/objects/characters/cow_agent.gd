extends KinematicBody

const POO_INTERVAL = 20


# stuff
var label 
var labelAnchor 
var cam

var digestion = 0
var pooTimer = 0
var health = 50
var timeAlive = 0;

func _process(_delta):
	timeAlive += _delta
	
	if digestion > 0:
		pooTimer += _delta
		if pooTimer > POO_INTERVAL:
			make_poo()
			pooTimer = 0;
			digestion -=1;
	
	label.set_text(make_text())
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

func make_poo():
	print("poooooooooooooo")
	pass
	
func make_text():
	return "cow %d : %d" % [health,digestion]
