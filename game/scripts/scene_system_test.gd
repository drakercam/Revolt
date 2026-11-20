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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

	# build world-space AABBs for districts
	var b1 = $District1/CollisionShape3D
	district_one_bounds = AABB(b1.position, b1.scale)

	var b2 = $District2/CollisionShape3D
	district_two_bounds = AABB(b2.position, b2.scale)

	var b3 = $District3/CollisionShape3D
	district_three_bounds = AABB(b3.position, b3.scale)

	var b4 = $District4/CollisionShape3D
	district_four_bounds = AABB(b4.position, b4.scale)
	
	print("District1 node pos:", $District1.global_position)
	print("District2 node pos:", $District2.global_position)
	print("District3 node pos:", $District3.global_position)
	print("District4 node pos:", $District4.global_position)
	
	# instantiate a leader_protestor to the scene
	var leader_protestor : LeaderProtestor = leader_protestor_scene.instantiate()
	# initialize the protest mechanic references
	leader_protestor.district_one_bounds = district_one_bounds
	leader_protestor.district_two_bounds = district_two_bounds
	leader_protestor.district_three_bounds = district_three_bounds
	leader_protestor.district_four_bounds = district_four_bounds
	leader_protestor.protestor_system = protestor_system
	leader_protestor_system.add_entity(leader_protestor)
	leader_protestor_system.get_entity(0).position = Vector3(0, 0.013, 0.714)
	leader_protestor_system.get_entity(0).health = 80
	
	# instantiate a revolution_base to the scene
	var revolution_base : RevolutionBase = revolution_base_scene.instantiate()
	# need references inside the revolution base that can be accessed
	revolution_base.common_people_system = common_person_system
	revolution_base.leader_protestor_system = leader_protestor_system
	revolution_base.protestor_system = protestor_system
	revolution_base.radio_tower_system = radio_tower_system
	
	revolution_base_system.add_entity(revolution_base)
	revolution_base_system.get_entity(0).position = Vector3(5.279, 0.0, -3.69)
	revolution_base_system.get_entity(0).scale = Vector3(0.5, 0.5, 0.5)
	revolution_base_system.get_entity(0).rotate(Vector3(0,1,0), 128.2)
	
	# instantiate a radio_tower to the scene
	var radio_tower : RadioTower = radio_tower_scene.instantiate()
	radio_tower_system.add_entity(radio_tower)
	radio_tower_system.get_entity(0).position = Vector3(-5.279, 0.0, -3.69) 
	radio_tower_system.get_entity(0).scale = Vector3(1,1,1)
	radio_tower_system.get_entity(0).rotate(Vector3(0,1,0), -128.2)
	
	# instantiate a couple normal protestors
	var protestor1 : Protestor = protestor_scene.instantiate()
	var protestor2 : Protestor = protestor_scene.instantiate()
	protestor1.district_one_bounds = district_one_bounds
	protestor1.district_two_bounds = district_two_bounds
	protestor1.district_three_bounds = district_three_bounds
	protestor1.district_four_bounds = district_four_bounds
	protestor2.district_one_bounds = district_one_bounds
	protestor2.district_two_bounds = district_two_bounds
	protestor2.district_three_bounds = district_three_bounds
	protestor2.district_four_bounds = district_four_bounds
	protestor_system.add_entity(protestor1)
	protestor_system.add_entity(protestor2)
	protestor_system.get_entity(0).position = Vector3(-4, 0.013, -4)
	protestor_system.get_entity(1).position = Vector3(4, 0.013, 4)
	protestor_system.get_entity(0).health = 80
	protestor_system.get_entity(1).health = 80
	
	# instantiate a common_person to the scene
	var common_person : CommonPerson = common_person_scene.instantiate()
	common_person_system.add_entity(common_person)
	common_person_system.get_entity(0).position = Vector3(0, 0.013, -0.714)	
	common_person_system.get_entity(0).setDissatisfactionLevel(80.0)
	
	# instantiate a tree_collectible to the scene
	var tree_collectible : TreeCollectible = tree_collectible_scene.instantiate()
	tree_collectible_system.add_entity(tree_collectible)
	tree_collectible_system.get_entity(0).position = Vector3(0, 0.013, 5)	
	
	# instantiate a ink_collectible to the scene
	var ink_collectible : InkCollectible = ink_collectible_scene.instantiate()
	ink_collectible_system.add_entity(ink_collectible)
	ink_collectible_system.get_entity(0).position = Vector3(0, 0.033, -5)
	
	# instantiate a megaphone_powerup to the scene
	var megaphone_powerup : MegaphonePowerup = megaphone_powerup_scene.instantiate()
	megaphone_powerup_system.add_entity(megaphone_powerup)
	megaphone_powerup_system.get_entity(0).position = Vector3(-4, 0.033, 0.5)
	
	# instantiate a megaphone_powerup to the scene
	var surveillance_drone : SurveillanceDrone = surveillance_drone_scene.instantiate()
	surveillance_drone_system.add_entity(surveillance_drone)
	surveillance_drone_system.get_entity(0).position = Vector3(-1, 1.5, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
