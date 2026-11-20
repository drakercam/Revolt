extends EntitySystem
class_name ProtestorSystem

var enemy_building_systems: Array[EnemyBuildingsSystem] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_nearest_building(p, system):
	var closest = null
	var closest_dist = INF
	
	for b in system.entities:
		var dist = p.global_position.distance_to(b.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = b
	
	return closest
	
func on_destruction_started(district_id: int):
	var target_system: EnemyBuildingsSystem = null
	
	# find correct district system
	for system in enemy_building_systems:
		if system.district_id == district_id:
			target_system = system
			break
	
	print("target_system=", target_system)
	
	if target_system == null:
		return
	
	# assign each protestor a target
	for p in entities:
		if p.state != Protestor.FOLLOW_LEADER:
			continue
			
		var target = get_nearest_building(p, target_system)
		if target != null:
			p.set_target(target)
			print("target=", target)
			p.change_state(Protestor.ATTACK_STRUCTURES)
			print("state=", p.state)

func update_all(delta):
	# call base_entity_system update_all
	update_all_base(delta)
	
	# perform specific updates here
	for e in entities:
		e.update_entity(delta)
		#print("updating protestors")
