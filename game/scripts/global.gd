extends Node

@export var morale : float
@export var buildings_left : int
@export var tree_paper : int
@export var ink : int
@export var tree_wood : int
@export var recruitable_count : int
@export var tree_count : int
@export var ink_count : int
@export var megaphone_count : int

var leader_protestor_system : LeaderProtestorSystem
var protestor_system : ProtestorSystem
var radio_tower_system : RadioTowerSystem
var revolution_base_system : RevolutionBaseSystem
var riot_police_system : RiotPoliceSystem
var surveillance_drone_system : SurveillanceDroneSystem
var common_person_system : CommonPersonSystem
var tree_collectible_system : TreeCollectibleSystem
var ink_collectible_system : InkCollectibleSystem
var megaphone_powerup_system : MegaphonePowerupSystem
var enemy_buildings_system_d1 : EnemyBuildingsSystem
var enemy_buildings_system_d2 : EnemyBuildingsSystem
var enemy_buildings_system_d3 : EnemyBuildingsSystem
var enemy_buildings_system_d4 : EnemyBuildingsSystem
var main_gameplay_scene

var districts = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	morale = 10
	buildings_left = 11
	tree_paper = 0
	ink = 0
	tree_wood = 0
	recruitable_count = 0
	tree_count = 0
	ink_count = 0
	megaphone_count = 0

func has_resources(cost: Dictionary) -> bool:
	return tree_paper >= cost.paper and tree_wood >= cost.wood and ink >= cost.ink

func spend_resources(cost: Dictionary) -> void:
	tree_paper -= cost.paper
	tree_wood -= cost.wood
	ink -= cost.ink

func set_districts(bounds_array: Array) -> void:
	districts = bounds_array

func point_in_district(pos: Vector3, box: AABB) -> bool:
	return (
		pos.x >= box.position.x - (box.size.x / 2) and
		pos.x <= box.position.x + (box.size.x / 2) and
		pos.z >= box.position.z - (box.size.z / 2) and
		pos.z <= box.position.z + (box.size.z / 2)
	)

func get_district_from_position(pos: Vector3) -> int:
	for i in range(districts.size()):
		if point_in_district(pos, districts[i]):
			return i + 1  # districts are 1-based
			
	return -1
