extends BaseEntity
class_name CommonPerson

@onready var global_vars = get_node("/root/global")
@onready var dissatisfaction : float
@onready var recruit : bool
@onready var passionate : bool
@onready var progress_bar : ProgressBar = $Sprite3D/SubViewport/ProgressBar
@onready var animation: AnimationPlayer = $Model_Mesh/AnimationPlayer2

# for wandering
var wander_target: Vector3
var wander_timer: float = 0.0
var wander_interval: float = 5.0 # number of seconds between picking a new random point
var speed: float = 1.0

var MAX_DISSATISFACTION = 80.0

var district_id: int = -1

enum {
	WANDERING,
	DISPERSE
}

var state : int = WANDERING
var target_district : int = -1

# for recruitment
func canBeRecruited() -> bool:
	return randf() < 0.6
	
func isPassionate() -> bool:
	return randf() < 0.2

func play_move_animation() -> void:
	if animation.current_animation != "person/move_commoner":
		animation.play("person/move_commoner")

func stop_move_animation() -> void:
	if animation.is_playing():
		animation.stop()

func pick_random_position_in_specific_district(d_id: int) -> Vector3:
	var box: AABB = global_vars.districts[d_id - 1]

	var margin_x = box.size.x * 0.3
	var margin_z = box.size.z * 0.3

	var min_x = box.position.x - box.size.x / 2 + margin_x
	var max_x = box.position.x + box.size.x / 2 - margin_x
	var min_z = box.position.z - box.size.z / 2 + margin_z
	var max_z = box.position.z + box.size.z / 2 - margin_z

	var x = randf_range(min_x, max_x)
	var z = randf_range(min_z, max_z)

	return Vector3(clamp(x, min_x, max_x), global_position.y, clamp(z, min_z, max_z))

func pick_random_position_in_district() -> Vector3:
	return pick_random_position_in_specific_district(district_id)
	
func rotate_towards_direction(direction: Vector3, delta: float, rotation_speed: float = 8.0) -> void:
	direction.y = 0
	if direction.length() < 0.001:
		return
	# calc the target yaw angle
	var target_angle = atan2(direction.x, direction.z)
	target_angle += PI
	# smoothly interpolate to the target rotation
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
	
func wander(delta):
	wander_timer -= delta

	if wander_timer <= 0 or wander_target == null or global_position.distance_to(wander_target) < 0.2:
		wander_target = pick_random_position_in_district()
		wander_timer = wander_interval

	var move_vector = wander_target - global_position
	var distance = move_vector.length()
	if distance > 0.05:
		var move_step = move_vector.normalized() * min(speed * delta, distance)
		var next_pos = global_position + move_step
		global_position = next_pos
		rotate_towards_direction(move_vector.normalized(), delta)
		play_move_animation()
	else:
		stop_move_animation()

func choose_target_district() -> void:
	var districts = []
	for i in range(global_vars.districts.size()):
		var d = i + 1
		if d != district_id:
			districts.append(d)
	
	if districts.size() > 0:
		target_district = districts.pick_random()

func _on_destruction_started(district: int) -> void:
	# Only disperse if they are in the affected district
	if district_id == district:
		state = DISPERSE
		choose_target_district()

func disperse(delta):
	# Choose a district if not already selected
	if target_district <= 0:
		choose_target_district()
		wander_target = pick_random_position_in_specific_district(target_district)

	# Move toward the target position
	var move_vector = wander_target - global_position
	var distance = move_vector.length()

	if distance < 0.5:
		# Once inside the new district, return to wandering
		district_id = global_vars.get_district_from_position(global_position)
		if district_id == target_district:
			state = WANDERING
			target_district = -1
			wander_timer = 0.0
			stop_move_animation()
			return
		else:
			# Pick another point within the target district
			wander_target = pick_random_position_in_specific_district(target_district)
	else:
		var move_step = move_vector.normalized() * min(speed * delta * 2.0, distance)
		global_position += move_step
		rotate_towards_direction(move_vector.normalized(), delta)
		play_move_animation()

func update_entity(delta):
	update_entity_base(delta)
	district_id = global_vars.get_district_from_position(self.global_position)
	
	if state == WANDERING:
		wander(delta)
	elif state == DISPERSE:
		disperse(delta)
	
	progress_bar.value = dissatisfaction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dissatisfaction = 0.0
	recruit = canBeRecruited()
	print("DEBUG: Can be recruited=", recruit)
	passionate = isPassionate()
	print("DEBUG: Is passionate=", passionate)
	
	animation.stop()
	
	district_id = global_vars.get_district_from_position(self.global_position)
	if district_id <= 0:
		district_id = 1  # fallback to district 1 if spawn is outside
	
	var leaders = get_tree().get_nodes_in_group("leader")
	for leader in leaders:
		if not leader.is_connected("destruction_started", Callable(self, "_on_destruction_started")):
			leader.connect("destruction_started", Callable(self, "_on_destruction_started"))
	
	animation.stop()
	progress_bar.max_value = MAX_DISSATISFACTION
	
	if !recruit:
		progress_bar.hide()
	else:
		progress_bar.show()
		progress_bar.get_theme_stylebox("background").bg_color = Color(0.001, 0.0, 0.142, 1.0)
		if passionate:
			progress_bar.get_theme_stylebox("fill").bg_color = Color(0.449, 0.002, 0.723, 1.0)
		else:
			progress_bar.get_theme_stylebox("fill").bg_color = Color(0.811, 0.534, 0.0, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# specific functions for dissatisfaction
func setDissatisfactionLevel(amount : float) -> void:
	if (amount <= 0):
		return
	dissatisfaction += amount
	print("dissatisfaction level=", dissatisfaction)
	dissatisfaction = min(dissatisfaction, MAX_DISSATISFACTION)

func getDissatisfactionLevel() -> float:
	return dissatisfaction
