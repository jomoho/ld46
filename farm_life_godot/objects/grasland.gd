extends "tool.gd"

const MAX_GROW_TIME = 30
const MAX_HITS = 5

export var growTime = 0

var startTransform
var progress
var hits = 0
var grasScene

func _ready():
	grasScene = load("res://objects/gras.tscn")
	startTransform = Transform($MeshInstance.transform)
	pass # Replace with function body.

func _process(_delta):
	growTime += _delta
	progress = min(growTime, MAX_GROW_TIME )/MAX_GROW_TIME
	print(progress)
	$MeshInstance.transform=startTransform.scaled(Vector3(1,progress,1))


func _on_Area_body_entered(body):
	print("%s entered" % name)
	print(body.name)
	body.enter_grasland(self)
	pass


func _on_Area_body_exited(body):
	body.exit_area(self)
	pass

func harvest_hit():
	if growTime > MAX_GROW_TIME:
		hits += 1
		if hits > MAX_HITS:
			growTime = 0;
			hits = 0;
			var gras = grasScene.instance()
			gras.set_global_transform($spawn.get_global_transform())
			get_tree().get_root().add_child(gras)


func make_text():
	if(hits > 0):
		return "HARVEST: %d/%d"  % [hits,MAX_HITS]
	else:
		return "grasland %d/100"  % (progress*100)
