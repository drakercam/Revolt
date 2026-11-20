extends BaseEntity
class_name TreeCollectible

@onready var timer : Timer = $Timer
@onready var global_vars = get_node("/root/global")

var collected : bool
var collector
var others

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collected = false
	others = []
	collector = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_entity(delta):
	update_entity_base(delta)
	
	# specific update logic 

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("protester"):
		return
	
	var body_parent = body.get_parent_node_3d()
	if body_parent.state != 2: # checks if they're actually collecting or just there
		return
	
	body_parent.state = 0
	body_parent.occupied = true
	
	if collector != null:
		others.append(body_parent)
		return
	
	print("at tree")
	timer.start(2)
	collector = body_parent

func _on_timer_timeout() -> void:
	print("collect a tree")
	collector.paper += 15
	collector.wood += 10
	collector.state = 3
	collector.occupied = false
	
	for o in others:
		o.state = 2
		o.occupied = false
	
	collected = true
	global_vars.tree_count -= 1
