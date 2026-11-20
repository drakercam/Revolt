extends BaseEntity
class_name Protestor

@onready var protester: RigidBody3D = $RigidBody3D
@onready var global_vars = get_node("/root/global")
@onready var animation: AnimationPlayer = $RigidBody3D/Model_Mesh/AnimationPlayer2
@onready var animation_timer: Timer = $AnimationTimer

var current_district: int
var target_district: int

var health : int
var occupied : bool
var leader : Node3D
var speed : int
@export var state : int
var collectible_type : String
@export var paper : int
@export var ink : int
@export var wood : int
var pdelta : float

# for building destruction
var target_building: BaseEntity = null
var attack_range = 2.0
var attack_damage = 10.0
var attack_cooldown = 3.0
var attack_timer = 0.0

enum {
	IDLE,
	FOLLOW_LEADER,
	GATHER_RESOURCES,
	RETURN_RESOURCES,
	CROWD_DISTRICT,
	ATTACK_STRUCTURES,
	INSPIRED,
	DISPERSE
}

func change_state(s):
	state = s

func getOccupied() -> bool:
	return occupied
	
func setOccupied(b: bool):
	occupied = b
	
func set_target(t):
	target_building = t

func _ready() -> void:
	health = 100
	occupied = false
	speed = 150.0
	state = IDLE
	paper = 0
	ink = 0
	wood = 0
	collectible_type = ""
	current_district = -1
	target_district = -1
	animation.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_entity(delta)

func update_entity(delta):
	update_entity_base(delta)
	
	if target_building == null or !is_instance_valid(target_building):
		target_building = null
	
	pdelta = delta
	
	current_district = global_vars.get_district_from_position(protester.global_position)
	
	# specific update logic 
	if state == IDLE: 
		animation.stop()
	elif state == FOLLOW_LEADER:
		follow(delta)
	elif state == GATHER_RESOURCES:
		gather_resources()
	elif state == RETURN_RESOURCES:
		return_resources()
	elif state == CROWD_DISTRICT:
		crowd_district()
	elif state == ATTACK_STRUCTURES:
		attack_target(delta)
	elif state == INSPIRED:
		be_inspired()
	elif state == DISPERSE:
		print("bleh")
		disperse()

func set_leader(l):
	leader = l
	
func be_inspired():
	animation.play("protester/protesting_protester")
	if animation_timer.is_stopped():
		animation_timer.start(3.7)

func _on_animation_timer_timeout() -> void:
	state = FOLLOW_LEADER

func attack_target(delta):
	if target_building != null and is_instance_valid(target_building):
		var dist = protester.global_position.distance_to(target_building.global_position)
		if dist > attack_range:
			move(target_building)
		else:
			attack_timer -= delta
			if attack_timer <= 0:
				attack_timer = attack_cooldown
				animation.play("protester/protesting_protester")
				target_building.take_damage(attack_damage)
				
		if target_building.is_dead():
			self.state = FOLLOW_LEADER

func follow(delta):
	if leader:
		if !leader.is_in_group("leader"):
			return
		
		var distance = protester.global_position.distance_to(leader.global_position)
		
		if distance > 1.0:
			move(leader)
		else:
			animation.stop()
	return

func gather_resources():
	var resource = find_closest_resource()
	
	if resource:
		if resource.is_in_group("tree"):
			collectible_type = "tree"
		else:
			collectible_type = "ink"
		 
		move(resource)
	return

func return_resources():
	var base = get_tree().get_first_node_in_group("base")
	
	if base:
		var distance = protester.global_position.distance_to(base.global_position)
		
		if distance <= 3.0:
			if collectible_type == "tree":
				global_vars.tree_paper += paper
				global_vars.tree_wood += wood
				paper = 0
				wood = 0
				print("paper = ", global_vars.tree_paper)
				print("wood = ", global_vars.tree_wood)
			elif collectible_type == "ink":
				global_vars.ink += ink
				ink = 0
				print("ink = ", global_vars.ink)
			state = IDLE
		else:
			move(base)
	return

func find_crowding_bounds(district_bounds):
	var offset = 10
	var new_bounds = district_bounds
	
	new_bounds.size -= Vector3(offset, offset, offset)
	
	return new_bounds

func crowd_district():
	if target_district <= 0:
		return
	
	var bounds = find_crowding_bounds(global_vars.districts[target_district - 1])
	
	if global_vars.point_in_district(protester.global_position, bounds):
		state = IDLE
		target_district = -1
		return
	
	# otherwise move towards the bounds
	move(bounds.position)

func disperse():
	# find target district
	var rn_d
	var ds = [1, 2, 3, 4]
	
	if target_district <= 0:
		var curr_d = global_vars.get_district_from_position(protester.global_position)
		ds.erase(curr_d)
		print(ds)
		rn_d = int(ds.pick_random())
		print(rn_d)
		target_district = rn_d
	
	# reuse crowd_district()
	print("DEBUG: DISPERSE TARGET = ", target_district)
	crowd_district()

func move(target):
	animation.play("protester/move_protester")
	if target is Vector3:
		$NavigationAgent3D.set_target_position(target)
	else:
		$NavigationAgent3D.set_target_position(target.global_position)
	var next_pos = $NavigationAgent3D.get_next_path_position()
	var direction = (Vector3(next_pos.x, 0.078, next_pos.z) - protester.global_position).normalized()
	
	protester.global_position += direction * 0.01 * speed * pdelta
	protester.look_at(Vector3(next_pos.x, 0.078, next_pos.z), Vector3.UP)

func find_closest_resource():
	var trees = get_tree().get_nodes_in_group("tree")
	var inks = get_tree().get_nodes_in_group("ink")
	var all_resources = trees + inks
	
	if all_resources.size() <= 0:
		state = IDLE
	
	var closest_resource: Node3D = null
	var min_dist = INF
	
	for resource in all_resources:
		var dist = protester.global_position.distance_to(resource.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_resource = resource
	
	return closest_resource
