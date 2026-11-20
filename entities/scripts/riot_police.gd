extends BaseEntity
class_name RiotPolice

@onready var animation: AnimationPlayer = $RigidBody3D/Model_Mesh/AnimationPlayer2
@onready var global_vars = get_node("/root/global")
@onready var arrest_timer: Timer = Timer.new()
var arrest_distance: float = 1.5
var is_arresting: bool = false

var riot_police_system : RiotPoliceSystem

enum {
	WATCHING,
	ARRESTING,
	CHASING
}

var district_id : int = -1
var state : int = WATCHING
var target_leader: Node3D = null
var speed: float = 100.0
var pdelta : float
var protest_over : bool
var is_violent : bool = false
var death : bool = false

var despawn : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.stop()
	district_id = global_vars.get_district_from_position(self.position)
	
	arrest_timer.one_shot = true
	arrest_timer.wait_time = 3.0  # Duration of arrest animation
	arrest_timer.timeout.connect(_on_arrest_timer_timeout)
	add_child(arrest_timer)
	
	var leaders = get_tree().get_nodes_in_group("leader")
	for leader in leaders:
		if not leader.is_connected("protest_started", Callable(self, "_on_protest_started")):
			leader.connect("protest_started", Callable(self, "_on_protest_started"))
		if not leader.is_connected("destruction_started", Callable(self, "_on_destruction_started")):
			leader.connect("destruction_started", Callable(self, "_on_destruction_started"))
		if not leader.is_connected("leader_escaped", Callable(self, "_on_leader_escaped")):
			leader.connect("leader_escaped", Callable(self, "_on_leader_escaped"))
			
	var drones = get_tree().get_nodes_in_group("drone")
	for drone in drones:
		if not drone.is_connected("leader_detected", Callable(self, "on_drone_detected_leader")):
			drone.connect("leader_detected", Callable(self, "on_drone_detected_leader"))
	
	protest_over = false

func _on_leader_escaped(escaped_district: int) -> void:
	# If the riot police belong to the district where the protest was dispersed,
	# stop chasing and mark them for despawn.
	if district_id == escaped_district:
		target_leader = null
		change_state(WATCHING)
		despawn = true

func change_state(s : int):
	if state == s:
		return
	state = s

func _on_protest_started(district: int) -> void:
	if district_id == district:
		change_state(WATCHING)

func _on_destruction_started(district: int) -> void:
	if district_id == district:
		change_state(ARRESTING)
		is_violent = true
		print("is_violent=", is_violent)
		
func on_drone_detected_leader(leader: Node3D):
	target_leader = leader
	#if state == ARRESTING:  # only chase if idle
		#change_state(CHASING)

func update_entity(delta):
	update_entity_base(delta)
	# specific update logic here
	
	if despawn:
		if riot_police_system:
			riot_police_system.erase_entity(self)
		return
	
	district_id = global_vars.get_district_from_position(self.position)
	pdelta = delta
	
	if target_leader != null and state == ARRESTING:
		change_state(CHASING)
	
	if state == WATCHING:
		watching()
	elif state == ARRESTING:
		arresting()
	elif state == CHASING:
		chasing(target_leader)

func watching():
	pass

func arresting():
	#print("Riot Police are arresting now")
	pass

func chasing(target):
	if target == null or is_arresting:
		return
	
	if not is_instance_valid(target):
		target_leader = null
		change_state(WATCHING)
		return
	
	animation.play("protester/move_police")
	var t
	if target is Vector3:
		$NavigationAgent3D.set_target_position(target)
		t = target
	else:
		$NavigationAgent3D.set_target_position(target.global_position)

	var dist = $RigidBody3D.global_position.distance_to(target.global_position)
	if dist <= arrest_distance:
		start_arrest(target)
		return
	
	var next_pos = $NavigationAgent3D.get_next_path_position()
	var direction = (Vector3(next_pos.x, 0.078, next_pos.z) - $RigidBody3D.global_position).normalized()
	
	$RigidBody3D.global_position += direction * 0.01 * speed * pdelta
	$RigidBody3D.look_at(Vector3(next_pos.x, 0.078, next_pos.z), Vector3.UP)
	
	if protest_over && global_vars.get_district_from_position(t) == district_id:
		death = true
		return

func start_arrest(leader: Node3D) -> void:
	print("DEBUG: is_arresting=", is_arresting)
	if is_arresting:
		return

	print("DEBUG: MADE IT HERE 2")
	
	is_arresting = true
	change_state(ARRESTING)
	target_leader = null

	print("DEBUG: Riot Police Arresting leader")

	animation.play("leader/arrested")
	leader.get_parent().on_arrested()
	arrest_timer.start()
	print("DEBUG: MADE IT HERE 3")

func _on_arrest_timer_timeout() -> void:
	if riot_police_system:
		riot_police_system.erase_entity(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
