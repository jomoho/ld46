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
var wheelbarrow = null

var equipedAnchor
var carryAnchor
var pooAnchor
var wheelbarrowAnchor


var gravity = -9.8
var velocity = Vector3()
export(NodePath)  var cameraPath
export(NodePath)  var meshPath
export(NodePath)  var animTreePath
export(NodePath)  var skeletonPath

var camera
var mesh
var animTree
var skeleton
var rightHandBoneId

const SPEED = 6
const ACCELERATION = 3
const DE_ACCELERATION = 5

var drive = false;


func _ready():
	cam = get_tree().get_root().get_camera()
	label = get_node("Label")
	labelAnchor = get_node("LabelAnchor")
	camera = get_node(cameraPath)
	mesh = get_node(meshPath)
	animTree = get_node(animTreePath)
	#TODO fix hand bone alignment
	skeleton = get_node(skeletonPath)
	rightHandBoneId = skeleton.find_bone("defhand_r")
	print("right hand bone: %d"% rightHandBoneId)
	
	equipedAnchor = get_node("farmer_rig/equiped_anchor")
	carryAnchor = get_node("farmer_rig/carry_anchor")
	pooAnchor = get_node("farmer_rig/poo_anchor")
	wheelbarrowAnchor = get_node("farmer_rig/wheelbarrow_anchor")

func _process(_delta):
	timeAlive += _delta
	actionCounter += _delta
	## adjust label position
	var pos = labelAnchor.get_global_transform().origin;
	var screenPos = cam.unproject_position(pos);
	label.set_position(screenPos);

	if actionCounter > 0.3:
		if(Input.is_action_pressed("drop")):
			actionCounter = 0
			if drive:
				drive = false
			elif stack.size() > 0:
				if wheelbarrow != null:
					wheelbarrow.load_stack(drop_stack())
				else:
					drop_stack()
			elif wheelbarrow != null and wheelbarrow.is_loaded():
				wheelbarrow.unload_stack(self)
			elif equiped != null:
				actionCounter = 0
				drop_tool()

	#TODO: better action/ interaction system
		if(Input.is_action_pressed("action")):
			actionCounter = 0
			if wheelbarrow != null:
				drive = true;
			elif interactable != null:
				print("action on %s" %interactable.name)
				if interactable.is_in_group('poo'):
					if equiped.is_in_group('pitchfork'):
						if not animTree.get("parameters/cleanup/active"):
							var poo = interactable
							animTree.set("parameters/cleanup/active", true)
							yield(get_tree().create_timer(1), "timeout")
							animTree.set("parameters/cleanup/active", false)
							pick_to_carry(poo)
							
				elif interactable.is_in_group( 'can_carry'):
					pick_to_carry(interactable)
				elif interactable.is_in_group('cow') and equiped == null:
					milk_cow(interactable)
				elif interactable.is_in_group('grasland'):
					if equiped != null:
						if equiped.is_in_group( 'sickle'):
							if interactable.harvest_hit():
								if not animTree.get("parameters/harvest/active"):
									animTree.set("parameters/harvest/active", true)
									yield(get_tree().create_timer(1), "timeout")
									animTree.set("parameters/harvest/active", false)
				elif interactable.is_in_group('tool'):
					pick_up_tool(interactable)

	if equiped != null:
		equiped.set_transform(right_hand())

	var carry = false
	for i in range(stack.size()):
		if stack[i].is_in_group("poo"):
			stack[i].set_transform(pooAnchor.get_global_transform())
		else:
			carry = true
			stack[i].set_transform(carryAnchor.get_global_transform())
	if carry:
		animTree.set("parameters/carry/blend_amount", 1)
	else:
		animTree.set("parameters/carry/blend_amount", 0)
	if drive and wheelbarrow != null:
		wheelbarrow.set_transform(wheelbarrowAnchor.get_global_transform())
		#$farmer_rig/joint.node_b_path = wheelbarrow.get_path()
	pass

func right_hand():
	var rht = skeleton.get_bone_pose(rightHandBoneId)
	var t = mesh.get_global_transform()
	return rht *t
	#transform.xform(skeleton.get_bone_global_pose(rightHandBoneId))
	#return equipedAnchor.get_global_transform() #transform.xform(skeleton.get_bone_global_pose(rightHandBoneId))



func _physics_process(delta):
	var dir = Vector3()
	var walking =false
	if(Input.is_action_pressed("move_up")):
		dir -= camera.get_global_transform().basis[2]
		walking =true
	if(Input.is_action_pressed("move_back")):
		dir += camera.get_global_transform().basis[2]
		walking =true
	if(Input.is_action_pressed("move_left")):
		dir -= camera.get_global_transform().basis[0]
		walking =true
	if(Input.is_action_pressed("move_right")):
		dir += camera.get_global_transform().basis[0]
		walking =true

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
	animTree.set("parameters/idle-walk/blend_amount", velocity.length()/SPEED)
	animTree.set("parameters/walk-speed/scale", 0.5*(velocity.length()))
	
	if walking:
		$sfxWalk.playing = true
	else:
		$sfxWalk.playing = false

func enter_poo(body):
	print("poo body entered")
	if equiped != null:
		if equiped.is_in_group("pitchfork"):
			interactable = body
			label.set_text("Press ACTION to clean up the poo!")
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
	if body.has_milk():
		label.set_text("press ACTION to milk cow %s " % body.name);
	elif not body.is_hungry():
		if body.is_digesting():
			label.set_text("wait for cow %s to poo before milking!" % body.name);
		else: 
			label.set_text("Feed %s if you want to milk her!" % body.name);
	else:
		label.set_text("Cow %s is hungry feed her some gras!" % body.name);
	interactable = body
	pass

func enter_tool(body):
	print("tool body entered")
	label.set_text("press ACTION to pick up %s" % body.name);
	interactable = body
	pass

func enter_grasland(body):
	print("grasland body entered")
	if equiped != null:
		if equiped.is_in_group( "sickle"):
			interactable = body
			label.set_text("Press ACTION to harvest gras!")
	else:
		label.set_text("Pick up the s	ickle to cut the gras!")
	interactable = body
	pass

func enter_dungheap(body):
	print("dungheap body entered")
	if stack.size() == 0:
		label.set_text("Pick up the pitchform to clean the poo!")
	else:
		label.set_text("Cleaning the poo... cows will be happy!")
	interactable = body
	pass

func exit_area(body):
	print("exit area")
	if body.is_in_group("wheelbarrow"):
		wheelbarrow = null
	
	if interactable != null:
		if interactable.get_instance_id() == body.get_instance_id():
			label.set_text("")
			if equiped != null:
				label.set_text("press DROP to drop %s" % equiped.name)
			interactable = null
	pass

func drop_stack():
	print("pick up stack" )
	var x = stack.pop_back()
	x.drop()
	x.set_axis_velocity(Vector3.UP)
	$sfxDrop.play()
	return x

func pick_up_tool(body):
	if equiped != null:
		drop_tool()
	$sfxPickupTool.play()
	equiped = body
	body.pick_up()
	print("pick up tool %s" % body.name)
	pass
	
func drop_tool():
	print("drop %s !" % equiped.name)
	$sfxDropTool.play()
	equiped.set_axis_velocity(Vector3.UP)
	equiped.drop()
	equiped = null;
	label.set_text("")
	pass

func pick_to_carry(body):
	print("pick_to_carry %s" % body.name)
	$sfxPickup.play()
	if body.is_in_group("milkcan"):
		label.set_text("Bring the milk to the kitchen to feed the Family");
	if body.is_in_group("poo"):
		label.set_text("Bring the poo to the dungheap to keep cows healthy!");

	if stack.size() < 1 or (stack.size() < 3 and body.is_in_group("poo")):
		body.pick_up()
		stack.push_back(body)
		body.transporter = self
	pass

func milk_cow(body):
	if body.has_milk():
		print("milk_cow")
		animTree.set("parameters/milk/active", true)
		yield(get_tree().create_timer(1.5), "timeout")
		body.milk_action(self)
		pass

func enter_wheelbarrow(body):
	wheelbarrow = body
	if stack.size() > 0:
		label.set_text("Press DROP to load item into wheelbarrow!")
	elif wheelbarrow.is_loaded():
		label.set_text("Press DROP to unload item\nand ACTION to drive")
	else:
		label.set_text("Load up some stuff to be more efficient!")
		
	pass
