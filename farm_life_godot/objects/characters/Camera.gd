extends Camera

# class member variables go here, for example:
export var distance = 4.0
export var height = 2.0
export(NodePath) var targetPath
var target

func _ready():
	# # Called every time the node is added to the scene.
	# # Initialization here
	target = get_node(targetPath)
	set_physics_process(true)
	set_as_toplevel(true)


func _physics_process(_delta):
	var target_pos = target.get_global_transform().origin
	var pos = get_global_transform().origin
	var up = Vector3(0,1,0)

	var offset = pos - target_pos

	offset = offset.normalized()*distance
	offset.y = height

	pos = target_pos + offset

	look_at_from_position(pos, target_pos, up)
