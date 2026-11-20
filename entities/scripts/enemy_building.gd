extends BaseEntity
class_name EnemyBuilding

@onready var global_vars = get_node("/root/global")
var riot_police_system : RiotPoliceSystem
var health = 100
var spawned_enemies: Array[RiotPolice] = []
var district_id : int = -1

func take_damage(amount: float):
	health -= amount

func is_dead() -> bool:
	return health <= 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	district_id = global_vars.get_district_from_position(self.global_position)
	
	var leaders = get_tree().get_nodes_in_group("leader")
	for leader in leaders:
		if not leader.is_connected("leader_escaped", Callable(self, "_on_leader_escaped")):
			leader.connect("leader_escaped", Callable(self, "_on_leader_escaped"))

func spawn_enemies():
	var count = 5
	
	for i in count:
		print("Spawned riot police, ", i)
		var enemy_scene = preload("res://entities/scenes/riot_police.tscn")
		var riot_police_instance = enemy_scene.instantiate()
		riot_police_instance.global_transform.origin = self.global_transform.origin + Vector3(-2.5 + randf(), 0, -2.5 + randf())
		riot_police_instance.riot_police_system = riot_police_system
		riot_police_system.add_entity(riot_police_instance)
		spawned_enemies.append(riot_police_instance)

func _on_leader_escaped(escaped_district: int):
	if escaped_district != district_id:
		return
	
	print("EnemyBuilding: Leader escaped from district ", escaped_district)
	
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.despawn = true
	
	spawned_enemies.clear()

func update_entity(delta):
	update_entity_base(delta)
	
	# specific update logic 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
