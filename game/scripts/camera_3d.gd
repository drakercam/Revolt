extends Camera3D

var speed = 500.0
var following = false #later for implementing following selected entities
var yaw = 0.0
var rotation_speed = 2.0
var min_height := 1.0
var max_height := 15.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# --- rotating left and right (yaw) ---
	if Input.is_action_pressed("turn_left"):
		yaw += rotation_speed * delta
	if Input.is_action_pressed("turn_right"):
		yaw -= rotation_speed * delta

	rotation.y = yaw

	# --- define diretion vectors --- 
	var forward = -transform.basis.z
	var right = transform.basis.x
	forward = forward.normalized()
	right = right.normalized()

	# --- movement ---
	var move_dir = Vector3.ZERO

	if Input.is_action_pressed("scroll_in"):
		move_dir += forward
	if Input.is_action_pressed("scroll_out"):
		move_dir -= forward
	if Input.is_action_pressed("move_left"):
		move_dir -= right
	if Input.is_action_pressed("move_right"):
		move_dir += right

	if move_dir != Vector3.ZERO:
		move_dir = move_dir.normalized()
		position += move_dir * speed * delta * 0.01

	forward.y = 0
	forward = forward.normalized()

	if Input.is_action_pressed("move_up"):
		position = position + speed * delta * forward * 0.01

	if Input.is_action_pressed("move_down"):
		position = position - speed * delta * forward * 0.01

	position.y = clamp(position.y, min_height, max_height)
