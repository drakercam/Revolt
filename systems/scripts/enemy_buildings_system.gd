extends EntitySystem
class_name EnemyBuildingsSystem

var district_id : int

func on_protest_started():
	print("DEBUG: PROTEST BEGAN IN DISTRICT", district_id)
	if entities.is_empty():
		return

	# pick a random enemy base to spawn enemies at
	var base = entities[randi() % entities.size()]
	base.spawn_enemies()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_all(delta):
	# call base_entity_system update_all
	update_all_base(delta)
	
	# perform specific updates here
	for e in entities:
		if !is_instance_valid(e) or e.is_dead():
			erase_entity(e)
		else:
			e.update_entity(delta)
		
		#print("updating common people")
