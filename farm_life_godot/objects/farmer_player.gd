extends KinematicBody

# stuff
var label
var labelAnchor
var cam
var timeAlive = 0
var actionCounter = 1
var equiped = null
var stack = []

var interactable = null

var equipedAnchor
var carryAnchor


var gravity = -9.8
var velocity = Vector3()
export(NodePath)  var cameraPath
export(NodePath)  var meshPath
var camera
var mesh

const SPEED = 6
const ACCELERATION = 3
const DE_ACCELERATION = 5


func _ready():
	cam = get_tree().get_root().get_camera()
	label = get_node("Label")
	labelAnchor = get_node("LabelAnchor")
	camera = get_node(cameraPath)
	mesh = get_node(meshPath)

	equipedAnchor = get_node("farmer_rig/equiped_anchor")
	carryAnchor = get_node("farmer_rig/carry_anchor")

func _process(_delta):
	timeAlive += _delta
	actionCounter += _delta
	## adjust label position
	var pos = labelAnchor.get_global_transform().origin;
	var screenPos = cam.unproject_position(pos);
	label.set_position(screenPos);

	if actionCounter > 0.5:
		if(Input.is_action_pressed("drop")):
			if equiped != null:
				actionCounter = 0
				print("drop %s !" % equiped.name)
				equiped.set_axis_velocity(Vector3.UP)
				equiped = null;
				label.set_text("")

		if(Input.is_action_pressed("action")):
			actionCounter = 0
			print("ACTION")
			if stack.size() > 0:
					drop_poo()
			elif interactable != null:
				print(interactable.name)
				if interactable.is_in_group('poo'):
					if equiped.is_in_group('pitchfork'):
						pick_up_poo(interactable)
				if interactable.is_in_group( 'grass'):
					pick_up_gras(interactable)
				if interactable.is_in_group('cow'):
					milk_cow(interactable)
				if interactable.is_in_group('grasland'):
					if equiped != null:
						if equiped.is_in_group( 'sickle'):
							#TODO: play harvest oneshot
							interactable.harvest_hit()
				if interactable.is_in_group('pitchfork') or  interactable.is_in_group('sickle'):
					pick_up_tool(interactable)

	if equiped != null:
		equiped.set_global_transform(equipedAnchor.get_global_transform())
	for x in stack:
		x.set_transform(carryAnchor.get_global_transform())



func _physics_process(delta):
	var dir = Vector3()

	if(Input.is_action_pressed("move_up")):
		dir -= camera.get_global_transform().basis[2]
	if(Input.is_action_pressed("move_back")):
		dir += camera.get_global_transform().basis[2]
	if(Input.is_action_pressed("move_left")):
		dir -= camera.get_global_transform().basis[0]
	if(Input.is_action_pressed("move_right")):
		dir += camera.get_global_transform().basis[0]

	dir.y = 0
	dir = dir.normalized()
	var t = mesh.get_transform()
	var rotTransform = t.looking_at(-dir,Vector3(0,1,0))

	mesh.set_transform(rotTransform)


	velocity.y += delta * gravity

	var hv = velocity
	hv.y = 0

	var new_pos = dir * SPEED
	var accel = DE_ACCELERATION

	if (dir.dot(hv) > 0):
		accel = ACCELERATION

	hv = hv.linear_interpolate(new_pos, accel * delta)

	velocity.x = hv.x
	velocity.z = hv.z

	velocity = move_and_slide(velocity, Vector3(0,1,0))

func enter_poo(body):
	print("poo body entered")
	if equiped != null:
		if equiped.is_in_group("pitchfork"):
			interactable = body
			label.set_text("Press [ACTION] to clean up the poo!")
	else:
		label.set_text("Pick up the pitchfork to clean the poo!")

	pass

func enter_gras(body):
	print("gras body entered")
	label.set_text("Feed the cows!");
	interactable = body
	pass

func enter_cow(body):
	print(" cow body entered")
	label.set_text("press [ACTION] to feed %s" % body.name);
	interactable = body
	pass

func enter_tool(body):
	print("tool body entered")
	label.set_text("press [ACTION] to pick up %s" % body.name);
	interactable = body
	pass

func enter_grasland(body):
	print("grasland body entered")
	if equiped != null:
		if equiped.is_in_group( "sickle"):
			interactable = body
			label.set_text("Press [ACTION] to harvest gras!")
	else:
		label.set_text("Pick up the s	ickle to cut the gras!")
	interactable = body
	pass

func exit_area(body):
	print("exit area")
	if interactable != null:
		if interactable.get_instance_id() == body.get_instance_id():
			label.set_text("")
			if equiped != null:
				label.set_text("press [DROP] to drop %s" % equiped.name)

			interactable = null
	pass

func pick_up_poo(body):
	print("pick up poo")
	if stack.size() < 3:
		stack.push_back(body)

func drop_poo():
	print("pick up poo")
	stack.pop_back()
	pass

func pick_up_tool(body):
	equiped = body
	print("pick up tool")
	pass

func pick_up_gras(body):
	print("pick up gras")
	pass

func milk_cow(body):
	print("milk_cow")
	pass
