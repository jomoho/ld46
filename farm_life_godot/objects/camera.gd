extends Camera

# class member variables go here, for example:
export var distance = 4.0
export var height = 2.0
export(NodePath) var targetPath
export(NodePath) var dollyPath
var dolly
var target
var mouse_sens = 0.3
var camera_anglev = 0

func _ready():
	# # Called every time the node is added to the scene.
	# # Initialization here
	target = get_node(targetPath)
	dolly = get_node(dollyPath)
	set_physics_process(true)
	set_as_toplevel(true)

# func _input(event):
# 	if event is InputEventMouseMotion:
# 		var yamount = deg2rad(-event.relative.x*mouse_sens)
# 		#print(yamount);
# 		#rotate_y(yamount)
# 		var changev=-event.relative.y*mouse_sens
# 		if camera_anglev+changev>-50 and camera_anglev+changev<50:
# 			camera_anglev+=changev
# 			dolly.rotate_x(-deg2rad(changev))

func _physics_process(_delta):
	var target_pos = target.get_global_transform().origin
	var pos = get_global_transform().origin
	var up = Vector3(0,1,0)

	var offset = pos - target_pos

	offset = offset.normalized()*distance
	offset.y = height

	pos = target_pos + offset
	look_at(target_pos, up)

	look_at_from_position(pos, target_pos, up)


