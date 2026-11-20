extends EntitySystem
class_name RevolutionBaseSystem

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
		e.update_entity(delta)
		#print("updating revolution bases")
