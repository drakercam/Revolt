extends Node3D

@onready var leader_protestor_system : LeaderProtestorSystem
@onready var protestor_system : ProtestorSystem
@onready var radio_tower_system : RadioTowerSystem
@onready var revolution_base_system : RevolutionBaseSystem
@onready var riot_police_system : RiotPoliceSystem
@onready var surveillance_drone_system : SurveillanceDroneSystem
@onready var common_person_system : CommonPersonSystem
@onready var tree_collectible_system : TreeCollectibleSystem
@onready var ink_collectible_system : InkCollectibleSystem
@onready var megaphone_powerup_system : MegaphonePowerupSystem

# for enemy buildings
@onready var enemy_buildings_system_d1 : EnemyBuildingsSystem
@onready var enemy_buildings_system_d2 : EnemyBuildingsSystem
@onready var enemy_buildings_system_d3 : EnemyBuildingsSystem
@onready var enemy_buildings_system_d4 : EnemyBuildingsSystem

var enemy_building_systems: Array[EnemyBuildingsSystem] = []

var enemy_building_1 = preload("res://entities/scenes/enemy_building_1.tscn")
var enemy_building_2 = preload("res://entities/scenes/enemy_building_2.tscn")
var enemy_building_3 = preload("res://entities/scenes/enemy_building_3.tscn")

@onready var global_vars = get_node("/root/global")
@onready var npc_spawn_timer : Timer = $Timers/NPCSpawnTimer
@onready var resource_spawn_timer : Timer = $Timers/ResourceSpawnTimer
@onready var megaphone_spawn_timer : Timer = $Timers/MegaphoneSpawnTimer

var leader_protestor_scene = preload("res://entities/scenes/leader_protester.tscn")
var protestor_scene = preload("res://entities/scenes/protester.tscn")
var radio_tower_scene = preload("res://entities/scenes/radio_tower.tscn")
var revolution_base_scene = preload("res://entities/scenes/revolution_base.tscn")
var riot_police_scene = preload("res://entities/scenes/riot_police.tscn")
var surveillance_drone_scene = preload("res://entities/scenes/surviellance_drone.tscn")
var common_person_scene = preload("res://entities/scenes/common_person.tscn")
var tree_collectible_scene = preload("res://entities/scenes/tree_collectible.tscn")
var ink_collectible_scene = preload("res://entities/scenes/ink_collectible.tscn")
var megaphone_powerup_scene = preload("res://entities/scenes/megaphone_powerup.tscn")

# for protest mechanic
var district_one_bounds : AABB
var district_two_bounds : AABB
var district_three_bounds : AABB
var district_four_bounds : AABB

var protest_location : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	npc_spawn_timer.start(3.0)
	resource_spawn_timer.start(5.0)
	
	protest_location = -1
	
	# instantiate the systems
	leader_protestor_system = LeaderProtestorSystem.new()
	add_child(leader_protestor_system)
	
	protestor_system = ProtestorSystem.new()
	add_child(protestor_system)
	
	radio_tower_system = RadioTowerSystem.new()
	add_child(radio_tower_system)
	
	revolution_base_system = RevolutionBaseSystem.new()
	add_child(revolution_base_system)
	
	riot_police_system = RiotPoliceSystem.new()
	add_child(riot_police_system)
	
	surveillance_drone_system = SurveillanceDroneSystem.new()
	add_child(surveillance_drone_system)
	
	common_person_system = CommonPersonSystem.new()
	add_child(common_person_system)
	
	tree_collectible_system = TreeCollectibleSystem.new()
	add_child(tree_collectible_system)
	
	ink_collectible_system = InkCollectibleSystem.new()
	add_child(ink_collectible_system)
	
	megaphone_powerup_system = MegaphonePowerupSystem.new()
	add_child(megaphone_powerup_system)
	
	# create enemy buildings systems
	enemy_buildings_system_d1 = EnemyBuildingsSystem.new()
	enemy_buildings_system_d2 = EnemyBuildingsSystem.new()
	enemy_buildings_system_d3 = EnemyBuildingsSystem.new()
	enemy_buildings_system_d4 = EnemyBuildingsSystem.new()
	
	global_vars.leader_protestor_system = leader_protestor_system
	global_vars.protestor_system = protestor_system
	global_vars.radio_tower_system = radio_tower_system
	global_vars.revolution_base_system = revolution_base_system
	global_vars.riot_police_system = riot_police_system
	global_vars.surveillance_drone_system = surveillance_drone_system
	global_vars.common_person_system = common_person_system
	global_vars.tree_collectible_system = tree_collectible_system
	global_vars.ink_collectible_system = ink_collectible_system
	global_vars.megaphone_powerup_system = megaphone_powerup_system
	global_vars.enemy_buildings_system_d1 = enemy_buildings_system_d1
	global_vars.enemy_buildings_system_d2 = enemy_buildings_system_d2
	global_vars.enemy_buildings_system_d3 = enemy_buildings_system_d3
	global_vars.enemy_buildings_system_d4 = enemy_buildings_system_d4
	global_vars.main_gameplay_scene = self
	global_vars.morale = 10
	global_vars.buildings_left = 11
	global_vars.tree_paper = 0
	global_vars.ink = 0
	global_vars.tree_wood = 0
	global_vars.recruitable_count = 0
	global_vars.tree_count = 0
	global_vars.ink_count = 0
	global_vars.megaphone_count = 0

	# build world-space AABBs for districts
	var b1 = $Districts/District1/CollisionShape3D
	district_one_bounds = AABB(b1.global_position, Vector3(23.9, 23.9, 23.9))

	var b2 = $Districts/District2/CollisionShape3D
	district_two_bounds = AABB(b2.global_position, Vector3(23.9, 23.9, 23.9))

	var b3 = $Districts/District3/CollisionShape3D
	district_three_bounds = AABB(b3.global_position, Vector3(23.9, 23.9, 23.9))

	var b4 = $Districts/District4/CollisionShape3D
	district_four_bounds = AABB(b4.global_position, Vector3(23.9, 23.9, 23.9))
	
	print("District1 node pos:", b1.global_position)
	print("District2 node pos:", b2.global_position)
	print("District3 node pos:", b3.global_position)
	print("District4 node pos:", b4.global_position)
	
	global_vars.set_districts([
		district_one_bounds,
		district_two_bounds,
		district_three_bounds,
		district_four_bounds
	])
	
	# instantiate a leader_protestor to the scene
	var leader_protestor : LeaderProtestor = leader_protestor_scene.instantiate()
	# initialize the protest mechanic references
	leader_protestor.protestor_system = protestor_system
	leader_protestor_system.add_entity(leader_protestor)
	leader_protestor_system.get_entity(0).position = Vector3(-10, 0.013, -10)
	leader_protestor_system.get_entity(0).health = 80
	
	leader_protestor_system.get_entity(0).connect("protest_started", Callable(self, "_on_protest_started"))
	leader_protestor_system.get_entity(0).connect("destruction_started", Callable(self, "_on_destruction_started"))
	leader_protestor_system.get_entity(0).connect("protest_ended", Callable(self, "_on_protest_ended"))
	
	# instantiate a revolution_base to the scene
	var revolution_base : RevolutionBase = $RevolutionBase
	# need references inside the revolution base that can be accessed
	revolution_base.common_people_system = common_person_system
	revolution_base.leader_protestor_system = leader_protestor_system
	revolution_base.protestor_system = protestor_system
	revolution_base.radio_tower_system = radio_tower_system
	
	revolution_base_system.add_entity(revolution_base)
	#revolution_base_system.get_entity(0).position = Vector3(5.279, 0.0, -3.69)
	revolution_base_system.get_entity(0).scale = Vector3(0.5, 0.5, 0.5)
	#revolution_base_system.get_entity(0).rotate(Vector3(0,1,0), 128.2)
	
	# instantiate a radio_tower to the scene
	var radio_tower : RadioTower = $radio_tower
	radio_tower_system.add_entity(radio_tower)
	#radio_tower_system.get_entity(0).position = Vector3(-5.279, 0.0, -3.69) 
	#radio_tower_system.get_entity(0).scale = Vector3(1,1,1)
	#radio_tower_system.get_entity(0).rotate(Vector3(0,1,0), -128.2)
	
	# instantiate a couple normal protestors
	var protestor1 : Protestor = protestor_scene.instantiate()
	var protestor2 : Protestor = protestor_scene.instantiate()
	protestor_system.add_entity(protestor1)
	protestor_system.add_entity(protestor2)
	protestor_system.get_entity(0).position = Vector3(-7, 0.013, -7)
	protestor_system.get_entity(1).position = Vector3(7, 0.013, 7)
	protestor_system.get_entity(0).health = 80
	protestor_system.get_entity(1).health = 80
	
	# instantiate a common_person to the scene
	#var common_person : CommonPerson = common_person_scene.instantiate()
	#common_person_system.add_entity(common_person)
	#common_person_system.get_entity(0).position = Vector3(-5, 0.013, -5)	
	#common_person_system.get_entity(0).setDissatisfactionLevel(80.0)
	#if common_person_system.get_entity(0).recruit:
		#global_vars.recruitable_count += 1
	
	# instantiate a megaphone_powerup to the scene
	var surveillance_drone : SurveillanceDrone = surveillance_drone_scene.instantiate()
	surveillance_drone_system.add_entity(surveillance_drone)
	#surveillance_drone_system.get_entity(0).position = Vector3(-1, 1.5, 1)

	# setup enemy basess
	
	# district 1
	var eb1_d1 : EnemyBuilding = $EnemyBuildingsDistrict1/EnemyBuilding1
	var eb2_d1 : EnemyBuilding = $EnemyBuildingsDistrict1/EnemyBuilding3
	eb1_d1.riot_police_system = riot_police_system
	eb2_d1.riot_police_system = riot_police_system
	enemy_buildings_system_d1.add_entity(eb1_d1)
	enemy_buildings_system_d1.add_entity(eb2_d1)
	enemy_buildings_system_d1.district_id = 1
	
	# district 2
	var eb1_d2 : EnemyBuilding = $EnemyBuildingsDistrict2/EnemyBuilding1
	var eb2_d2 : EnemyBuilding = $EnemyBuildingsDistrict2/EnemyBuilding2
	var eb3_d2 : EnemyBuilding = $EnemyBuildingsDistrict2/EnemyBuilding3
	eb1_d2.riot_police_system = riot_police_system
	eb2_d2.riot_police_system = riot_police_system
	eb3_d2.riot_police_system = riot_police_system
	enemy_buildings_system_d2.add_entity(eb1_d2)
	enemy_buildings_system_d2.add_entity(eb2_d2)
	enemy_buildings_system_d2.add_entity(eb3_d2)
	enemy_buildings_system_d2.district_id = 2
	
	# district 3
	var eb1_d3 : EnemyBuilding = $EnemyBuildingsDistrict3/EnemyBuilding1
	var eb2_d3 : EnemyBuilding = $EnemyBuildingsDistrict3/EnemyBuilding2
	var eb3_d3 : EnemyBuilding = $EnemyBuildingsDistrict3/EnemyBuilding3
	eb1_d3.riot_police_system = riot_police_system
	eb2_d3.riot_police_system = riot_police_system
	eb3_d3.riot_police_system = riot_police_system
	enemy_buildings_system_d3.add_entity(eb1_d3)
	enemy_buildings_system_d3.add_entity(eb2_d3)
	enemy_buildings_system_d3.add_entity(eb3_d3)
	enemy_buildings_system_d3.district_id = 3
	
	# district 4
	var eb1_d4 : EnemyBuilding = $EnemyBuildingsDistrict4/EnemyBuilding1
	var eb2_d4 : EnemyBuilding = $EnemyBuildingsDistrict4/EnemyBuilding2
	var eb3_d4 : EnemyBuilding = $EnemyBuildingsDistrict4/EnemyBuilding3
	eb1_d4.riot_police_system = riot_police_system
	eb2_d4.riot_police_system = riot_police_system
	eb3_d4.riot_police_system = riot_police_system
	enemy_buildings_system_d4.add_entity(eb1_d4)
	enemy_buildings_system_d4.add_entity(eb2_d4)
	enemy_buildings_system_d4.add_entity(eb3_d4)
	enemy_buildings_system_d4.district_id = 4
	
	enemy_building_systems.append(enemy_buildings_system_d1)
	enemy_building_systems.append(enemy_buildings_system_d2)
	enemy_building_systems.append(enemy_buildings_system_d3)
	enemy_building_systems.append(enemy_buildings_system_d4)
	
	# have the protestor system get a reference to the enemy building systems
	protestor_system.enemy_building_systems = enemy_building_systems
	
	# setup build spots
	var build_spot_1 : BuildSpot = $BuildSpots/BuildSpot1
	var build_spot_2 : BuildSpot = $BuildSpots/BuildSpot2
	var build_spot_3 : BuildSpot = $BuildSpots/BuildSpot3
	var build_spot_4 : BuildSpot = $BuildSpots/BuildSpot4
	var build_spot_5 : BuildSpot = $BuildSpots/BuildSpot5
	var build_spot_6 : BuildSpot = $BuildSpots/BuildSpot6
	
	build_spot_1.radio_tower_system = radio_tower_system
	build_spot_1.revolution_base_system = revolution_base_system
	build_spot_2.radio_tower_system = radio_tower_system
	build_spot_2.revolution_base_system = revolution_base_system
	build_spot_3.radio_tower_system = radio_tower_system
	build_spot_3.revolution_base_system = revolution_base_system
	build_spot_4.radio_tower_system = radio_tower_system
	build_spot_4.revolution_base_system = revolution_base_system
	build_spot_5.radio_tower_system = radio_tower_system
	build_spot_5.revolution_base_system = revolution_base_system
	build_spot_6.radio_tower_system = radio_tower_system
	build_spot_6.revolution_base_system = revolution_base_system

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_vars.buildings_left = enemy_buildings_system_d1.get_size() + enemy_buildings_system_d2.get_size() + enemy_buildings_system_d3.get_size() + enemy_buildings_system_d4.get_size()
	
	if global_vars.morale <= 0 || leader_protestor_system.get_size() <= 0:
		game_over(false)
	elif global_vars.morale >= $Camera3D/CanvasLayer2/UI.MAX_MORALE && global_vars.buildings_left <= 0:
		game_over(true)
	
	leader_protestor_system.update_all(delta)
	protestor_system.update_all(delta)
	radio_tower_system.update_all(delta)
	revolution_base_system.update_all(delta)
	riot_police_system.update_all(delta)
	surveillance_drone_system.update_all(delta)
	common_person_system.update_all(delta)
	tree_collectible_system.update_all(delta)
	ink_collectible_system.update_all(delta)
	megaphone_powerup_system.update_all(delta)
	enemy_buildings_system_d1.update_all(delta)
	enemy_buildings_system_d2.update_all(delta)
	enemy_buildings_system_d3.update_all(delta)
	enemy_buildings_system_d4.update_all(delta)
	
	if global_vars.recruitable_count < 15 && npc_spawn_timer.is_stopped():
		npc_spawn_timer.start(7.0)
	
	if (global_vars.tree_count < 12 || global_vars.ink_count < 12) && resource_spawn_timer.is_stopped():
		resource_spawn_timer.start(13.0)
	
	if (global_vars.megaphone_count < 2 && megaphone_spawn_timer.is_stopped()):
		megaphone_spawn_timer.start(10.0)

func spawn_common_person():
	var common_person : CommonPerson = common_person_scene.instantiate()
	common_person_system.add_entity(common_person)
	var end = common_person_system.get_size() - 1
	common_person_system.get_entity(end).position = Vector3(randf_range(-20, 20), 0.013, randf_range(-20, 20))
	common_person_system.get_entity(end).setDissatisfactionLevel(10.0)
	common_person_system.get_entity(end).district_id = global_vars.get_district_from_position(common_person_system.get_entity(end).position)
	
	if common_person_system.get_entity(end).recruit:
		global_vars.recruitable_count += 1

func _on_npc_spawn_timer_timeout() -> void:
	spawn_common_person()
	
func _on_protest_started(target_district: int) -> void:
	print("DEBUG: SIGNAL RECEIVED")
	for system in enemy_building_systems:
		if system.district_id == target_district:
			system.on_protest_started()
	protest_location = target_district
	megaphone_spawn_timer.start(3.0)

func _on_destruction_started(target_district: int) -> void:
	print("DEBUG: SIGNAL RECEIVED")
	protestor_system.on_destruction_started(target_district)

func _on_protest_ended(target_district: int) -> void:
	protest_location = -1

func _on_leader_detected(body: Node3D) -> void:
	print("DEBUG: SIGNAL RECEIVED")

func spawn_resources():
	if global_vars.tree_count < 15:
		# instantiate a tree_collectible to the scene
		var tree_collectible : TreeCollectible = tree_collectible_scene.instantiate()
		tree_collectible_system.add_entity(tree_collectible)
		var end = tree_collectible_system.get_size() - 1
		tree_collectible_system.get_entity(end).position = Vector3(randf_range(-4.5, 4.5), 0.013, randf_range(-4.5, 4.5))
		global_vars.tree_count += 1
	
	if global_vars.ink_count < 15: 
		# instantiate a ink_collectible to the scene
		var ink_collectible : InkCollectible = ink_collectible_scene.instantiate()
		ink_collectible_system.add_entity(ink_collectible)
		var end = ink_collectible_system.get_size() - 1
		ink_collectible_system.get_entity(end).position = Vector3(randf_range(-4.5, 4.5), 0.033, randf_range(-4.5, 4.5))
		global_vars.ink_count += 1

func spawn_megaphone():
	# instantiate a megaphone_powerup to the scene
	var megaphone_powerup : MegaphonePowerup = megaphone_powerup_scene.instantiate()
	megaphone_powerup_system.add_entity(megaphone_powerup)
	var end = megaphone_powerup_system.get_size() - 1
	var pos = generate_point_in_bounds(protest_location)
	if pos is Vector3:
		megaphone_powerup_system.get_entity(end).position = pos
		global_vars.megaphone_count += 1

func generate_point_in_bounds(d: int):
	if d == 1:
		return Vector3(randf_range(-16, -3), 0.033, randf_range(-16, -3))
	elif d == 2:
		return Vector3(randf_range(3, 16), 0.033, randf_range(-16, -3))
	elif d == 3:
		return Vector3(randf_range(-16, 3), 0.033, randf_range(3, 16))
	elif d == 4:
		return Vector3(randf_range(3, 16), 0.033, randf_range(3, 16))
	print("DEBUG: Invalid district #", d)

func _on_resource_spawn_timer_timeout() -> void:
	spawn_resources()

func _on_megaphone_spawn_timer_timeout() -> void:
	spawn_megaphone()

func game_over(winner) -> void:
	if winner:
		print("You Win!")
		for rp in riot_police_system.entities:
			riot_police_system.erase_entity(rp)
		for drone in surveillance_drone_system.entities:
			surveillance_drone_system.erase_entity(drone)
		get_tree().change_scene_to_file("res://game/scenes/win.tscn")
	else:
		print("You Lose.")
		for rp in riot_police_system.entities:
			riot_police_system.erase_entity(rp)
		for drone in surveillance_drone_system.entities:
			surveillance_drone_system.erase_entity(drone)
		get_tree().change_scene_to_file("res://game/scenes/lose.tscn")
