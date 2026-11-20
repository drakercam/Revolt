extends Node3D

@onready var leader_protestor_system : LeaderProtestorSystem
@onready var protestor_system : ProtestorSystem
@onready var radio_tower_system : RadioTowerSystem
@onready var revolution_base_system : RevolutionBaseSystem
@onready var riot_police_system : RiotPoliceSystem
@onready var surveillance_drone_system : SurveillanceDroneSystem

var leader_protestor_scene = preload("res://entities/scenes/leader_protester.tscn")
var protestor_scene = preload("res://entities/scenes/protester.tscn")
var radio_tower_scene = preload("res://entities/scenes/radio_tower.tscn")
var revolution_base_scene = preload("res://entities/scenes/revolution_base.tscn")
var riot_police_scene = preload("res://entities/scenes/riot_police.tscn")
var surveillance_drone_scene = preload("res://entities/scenes/surviellance_drone.tscn")

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
	
	# instantiate a leader_protestor to the scene
	var leader_protestor = leader_protestor_scene.instantiate()
	leader_protestor_system.add_entity(leader_protestor)
	leader_protestor_system.get_entity(0).position = Vector3(-4.982, 0.013, 2.714)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	leader_protestor_system.update_all(delta)
	protestor_system.update_all(delta)
	radio_tower_system.update_all(delta)
	revolution_base_system.update_all(delta)
	riot_police_system.update_all(delta)
	surveillance_drone_system.update_all(delta)
	
	# perform game running tasks
	game_running(delta)
	
func game_running(delta: float) -> void:
	pass
