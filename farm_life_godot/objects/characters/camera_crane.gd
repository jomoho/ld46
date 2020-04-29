extends Spatial

var mouse_sens = 0.1
var camera_angle_target = Vector3()
var camera_angle = Vector3()

var angle_drag = 10.0
var identity

func _ready():	
	identity = transform.translated(Vector3.ZERO)
	set_physics_process(true)
	pass


func _input(event):
	print(event)
	if event is InputEventMouseMotion:
		var change_x = event.relative.y * mouse_sens
		var change_y = -event.relative.x * mouse_sens
		camera_angle_target += Vector3(deg2rad(change_x), deg2rad(change_y), 0)
		print(camera_angle_target);

func _physics_process(_delta):	
	var diff = camera_angle_target - camera_angle
	camera_angle += angle_drag * _delta * diff
	var q = Quat()
	q.set_euler(camera_angle_target)
	transform = identity *Transform(q)
	pass
