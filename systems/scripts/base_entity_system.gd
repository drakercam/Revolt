extends Node
class_name EntitySystem

var entities: Array[BaseEntity] = []

func add_entity(e: BaseEntity):
	add_child(e)
	entities.append(e)
	
func erase_entity(e: BaseEntity):
	entities.erase(e)
	remove_child(e)
	e.queue_free()
	
func get_size():
	return entities.size()
	
func get_entity(index: int) -> BaseEntity:
	return entities.get(index)
	
func erase_entity_at(index: int):
	var e = entities.get(index)
	entities.remove_at(index)
	remove_child(e)
	e.queue_free()
	
func update_all_base(delta):
	for e in entities:
		e.update_entity_base(delta)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
