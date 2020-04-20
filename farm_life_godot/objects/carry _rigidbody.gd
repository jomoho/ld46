# Carry
extends RigidBody


const  MAX_LABEL_DISTANCE = 30
# stuff
var label
var labelAnchor
var cam

var timeAlive = 0;

export var dynamicText = true
export var ignoreDistanceCulling = false;
export var disableCollision = true

var transporter = null

var isCarried = false
# Called when the node enters the scene tree for the first time.
func _ready():
	cam = get_tree().get_root().get_camera()
	label = get_node("Label")
	labelAnchor = get_node("LabelAnchor")
	pass
	
func _process(_delta):
	timeAlive += _delta
	if(dynamicText):
		label.set_text(make_text())
	## adjust label position
	var pos = labelAnchor.get_global_transform().origin;

	
	var screenPos = cam.unproject_position(pos);
	label.set_position(screenPos);
	
	var direction = pos - cam.get_global_transform().origin
	var isVisible = false
	if direction.dot(cam.get_global_transform().basis.z) < 0:
		isVisible = true
	
	if direction.length() > MAX_LABEL_DISTANCE and not ignoreDistanceCulling:
		isVisible = false;

	if isVisible:
		label.show()
	else: # othwerwise we hide it
		label.hide()
	pass

func make_text():
	return name
	pass
	
func exit_area(body):
	pass
	
func pick_up():
	isCarried = true
	set_mode(RigidBody.MODE_CHARACTER)
	if disableCollision:
		get_node("Area/CollisionShape").disabled = true;
		print("disabled CollisionShape %s" % name)
	pass
	
func drop():
	isCarried = false
	transporter = null
	set_mode(RigidBody.MODE_RIGID)
	get_node("Area/CollisionShape").disabled = false;
	print("enabled CollisionShape %s", name)
	pass
	
func transporter_unload_stack():
	if transporter != null:
		if transporter.is_in_group("player"):
			transporter.drop_stack()
		elif transporter.is_in_group("wheelbarrow"):
			transporter.unload_from_stack(self)
