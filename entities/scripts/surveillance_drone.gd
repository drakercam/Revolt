extends BaseEntity
class_name SurveillanceDrone

@onready var animation: AnimationPlayer = $RigidBody3D/Model_Mesh/AnimationPlayer2
@onready var detection_space: Area3D = $Area3D

enum {
	PATROL,
	TRACK_LEADER
}

signal leader_detected(body: Node3D)

var state : int
var fly_height: float
var speed: int
var path_pts
var next_pt : int
var leader_body

func update_entity(delta):
	update_entity_base(delta)
	
	# specific update logic here
	if next_pt >= path_pts.size():
		next_pt -= path_pts.size()
	
	if leader_body != null:
		state = TRACK_LEADER
	else:
		state = PATROL
	
	if state == PATROL:
		patrol(delta)
	elif state == TRACK_LEADER:
		track_leader(delta)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("move/drone_fly")
	fly_height = 1.5
	speed = 100
	path_pts = [Vector3(-13, fly_height, -13), Vector3(13, fly_height, -13), 
		Vector3(13, fly_height, 13), Vector3(-13, fly_height, 13)]
	global_position = path_pts[0]
	state = PATROL
	next_pt = 1 
	leader_body = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func patrol(delta):
	var distance = global_position.distance_to(path_pts[next_pt])
	
	move(path_pts[next_pt], delta)
	
	if distance < 0.0075:
		next_pt += 1

func track_leader(delta):
	var distance = global_position.distance_to(leader_body.global_position)
	
	if distance > 2.0:
		move(leader_body, delta)

func move(target, delta):
	var distance
	var direction
	if target is Vector3:
		distance = global_position.distance_to(Vector3(target.x, fly_height, target.z))
		direction = (Vector3(target.x, fly_height, target.z) - global_position).normalized()
		self.look_at(Vector3(target.x, fly_height, target.z), Vector3.UP)
	else:
		distance = global_position.distance_to(Vector3(target.global_position.x, fly_height, target.global_position.z))
		direction = (Vector3(target.global_position.x, fly_height, target.global_position.z) - global_position).normalized()
		self.look_at(Vector3(target.global_position.x, fly_height, target.global_position.z), Vector3.UP)
	
	global_position += direction * 0.01 * speed * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !detection_space.visible:
		return
	
	if body.is_in_group("leader"):
		if body.get_parent().in_protest:
			print("leader detected")
			emit_signal("leader_detected", body)
