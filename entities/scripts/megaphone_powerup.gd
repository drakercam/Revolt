extends BaseEntity
class_name MegaphonePowerup

@onready var global_vars = get_node("/root/global")

var collected : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collected = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_entity(delta):
	update_entity_base(delta)
	
	# specific update logic 

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("leader"):
		return
	
	var body_parent = body.get_parent_node_3d()
	
	print("collect a powerup")
	body_parent.multiplier += 2
	body_parent.powerup_timer.start(10)
	global_vars.megaphone_count -= 1
	collected = true
