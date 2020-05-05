# Labeled
extends Spatial

const  MAX_LABEL_DISTANCE = 30

onready var label = $Label
onready var labelAnchor = $LabelAnchor
onready var cam = get_tree().get_root().get_camera()
onready var globals = get_node("/root/globals")

var timeAlive = 0;

export var dynamicText = true
export var ignoreDistanceCulling = false;
export var disableCollision = true

var transporter = null
var isCarried = false

func _ready():
	pass
	
func _process(_delta):
	label.set_visible( globals.settings.showLabels)
	if not globals.settings.showLabels:
		return
			
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
	
#func pick_up():
#	isCarried = true	
#	if disableCollision:
#		get_node("Area/CollisionShape").disabled = true;
#		print("disabled CollisionShape %s" % name)
#	pass
#
#func drop():
#	isCarried = false
#	transporter = null
#	get_node("Area/CollisionShape").disabled = false;
#	print("enabled CollisionShape %s", name)
#	pass
#
#func transporter_unload_stack():
#	if transporter != null:
#		if transporter.is_in_group("player"):
#			transporter.drop_stack()
#		elif transporter.is_in_group("wheelbarrow"):
#			transporter.unload_from_stack(self)
