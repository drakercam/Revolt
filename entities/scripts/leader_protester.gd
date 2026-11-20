extends BaseEntity
class_name LeaderProtestor

@onready var global_vars = get_node("/root/global")

@onready var popup_menu: PopupMenu = $CanvasLayer/PopupMenu
@onready var move_menu: PopupMenu = $CanvasLayer/MoveMenu
@onready var protest_menu: PopupMenu = $CanvasLayer/ProtestMenu
@onready var target: MeshInstance3D = $TargetPosition
@onready var leader: RigidBody3D = $RigidBody3D
@onready var powerup_timer: Timer = $Timers/PowerupTimer
@onready var animation_timer: Timer = $Timers/AnimationTimer
@onready var note_timer: Timer = $Timers/NoteTimer
@onready var animation: AnimationPlayer = $RigidBody3D/Model_Mesh/AnimationPlayer2
@onready var note1: ColorRect = $CanvasLayer/Note/NotePt1
@onready var note2: Label = $CanvasLayer/Note/NotePt2

# for protest component
var protestor_system: ProtestorSystem

var leader_district : int
var previous_district : int = -1
signal protest_started(district_id: int)
signal destruction_started(district_id: int)
signal protest_ended(district_id: int)
var in_protest : bool

var move_menu_up : bool
var moving : bool
var speed : int
var health : int
@export var multiplier : int
var state : int

enum {
	INSPIRE_CROWD,
	PROTEST,
	DISPERSE,
	INITIATE_DESTRUCTION,
	MOVE,
	HANDLE_PROTEST,
	ARRESTED
}

signal leader_escaped(district_id: int)

func change_state(s : int):
	state = s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target.hide()
	move_menu_up = false
	moving = false
	animation.stop()
	speed = 200
	health = 100
	multiplier = 0 # when it's used, check if it's 0 or not beforehand
	
	popup_menu.position = Vector2(20, 70)
	popup_menu.size = Vector2(200, 500)
	move_menu.position = Vector2(20, 10)
	move_menu.size = Vector2(200, 500)
	move_menu.exclusive = true
	protest_menu.position = Vector2(20, 70)
	protest_menu.size = Vector2(200, 500)
	
	add_to_group("leader")
	
	leader_district = getDistrict(leader.global_position)
	previous_district = leader_district

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_entity(delta)

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		popup_menu.popup()

func _on_popup_menu_id_pressed(id: int) -> void:
	if (id == MOVE):
		print("Move Leader")
		move_menu_up = true
		move_menu.popup()
		popup_menu.hide()
	
	elif (id == HANDLE_PROTEST):
		protest_menu.popup()
		popup_menu.hide()

func _on_move_menu_id_pressed(id: int) -> void:
	if (id == 0):
		moving = false
		animation.stop()
		target.hide()
	elif (id == 1):
		move_menu_up = false
		move_menu.hide()

func _on_protest_menu_id_pressed(id: int) -> void:
	if (id == INSPIRE_CROWD):
		if in_protest:
			inspire_crowd()
		else:
			note1.show()
			note2.text = "Please Start Protest First"
			note2.show()
			note_timer.start(10.0)
		
	elif (id == PROTEST):
		print("Protest Component")
		if !in_protest:
			print("Result of checkbounds=", checkBounds())
			if checkBounds():
				in_protest = true
				start_protest()
		else:
			note1.show()
			note2.text = "Already started a protest"
			note2.show()
			note_timer.start(10.0)
	
	elif (id == DISPERSE):
		if in_protest:
			print("Disperse Component (Retreat to either specified location or Revolution Base)")
			in_protest = false
			disperse_protest()
		else:
			note1.show()
			note2.text = "Please Start Protest First"
			note2.show()
			note_timer.start(10.0)
	
	elif (id == INITIATE_DESTRUCTION):
		if in_protest:
			print("Initiate structure destruction")
			destroy_structure()
		else:
			note1.show()
			note2.text = "Please Start Protest First"
			note2.show()
			note_timer.start(10.0)

func update_entity(delta):
	update_entity_base(delta)
	# specific update logic here
		
	var current_district = getDistrict(leader.global_position)
	
	# emit the signal only when the leader leaves the district after dispersing
	if not in_protest and previous_district != -1 and current_district != previous_district:
		print("DEBUG: Leader escaped from district ", previous_district)
		emit_signal("leader_escaped", previous_district)
	
	previous_district = current_district
		
	if Input.is_action_just_pressed("left_mouse") && move_menu_up:
		# https://www.youtube.com/watch?v=KT06pv06Q1U
		# used this video to learn how ray tracing works in godot
		# essentially ray tracing in godot
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 30
		
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		ray_query.collide_with_areas = false
		
		var result = space.intersect_ray(ray_query)
		print(result)
		if result.has("position"):
			var pos = result["position"]
			target.global_position = Vector3(pos.x, 0.013, pos.z)
			target.show()
			moving = true
	
	if moving:
		move(delta)

func move(delta):
	if animation_timer.is_stopped():
		animation.play("leader/move")
	
	var distance = leader.global_position.distance_to(target.global_position)
	var direction = (target.global_position - leader.global_position).normalized()
	
	leader.global_position += direction * 0.01 * speed * delta
	leader.look_at(target.global_position, Vector3.UP)
	
	if distance < 0.01: # might have to calibrate
		moving = false
		animation.stop()
		target.hide()
	
func inspire_crowd():
	leader_district = getDistrict(leader.global_position)
	
	if leader_district == -1:
		print("DEBUG: Leader not in any district")
		return
	
	print("DEBUG: Leader District = ", leader_district)
	
	animation.play("leader/inspiring")
	animation_timer.start(3.5)

func on_arrested() -> void:
	print("DEBUG: Leader Protestor Arrested")

	in_protest = false
	moving = false
	change_state(ARRESTED)

	animation.stop()
	animation.play("leader/arrested")

	# Disable interactions
	set_process(false)

	# Remove from the entity system after the animation
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 3.0
	timer.timeout.connect(_on_arrest_removal)
	add_child(timer)
	timer.start()

func _on_arrest_removal() -> void:
	print("DEBUG: Leader Protestor removing from system")

	var system : LeaderProtestorSystem = global_vars.leader_protestor_system
	if system and system.has_method("erase_entity"):
		system.erase_entity(self)
	else:
		queue_free()

func _on_animation_timer_timeout() -> void:
	var num_protesters = 0
	
	for p in protestor_system.entities:
		var p_district = getDistrict(p.protester.global_position)
		
		if p_district == leader_district && p.leader == leader && p.state == 1:
			num_protesters += 1
			p.change_state(6)
	
	if multiplier != 0:
		global_vars.morale += multiplier * 5 * num_protesters
	else:
		global_vars.morale += 5 * num_protesters

func point_in_district(pos: Vector3, box: AABB) -> bool:
	return (
		pos.x >= box.position.x - (box.size.x / 2) and
		pos.x <= box.position.x + (box.size.x / 2) and
		pos.z >= box.position.z - (box.size.z / 2) and
		pos.z <= box.position.z + (box.size.z / 2)
	)

func getDistrict(pos: Vector3) -> int:
	return global_vars.get_district_from_position(pos)

# this is where we will check if the leader protestor and subsequent protestors are all in the same district
func checkBounds() -> bool:
	leader_district = getDistrict(leader.global_position)
	print("Leader pos:", leader.global_position)
	print("Districts:", global_vars.districts)
	if leader_district == -1:
		print("DEBUG: Leader not in any district")
		return false
	
	print("DEBUG: Leader District = ", leader_district)
	
	var protestor_count = 0
	
	for p in protestor_system.entities:
		var p_district = getDistrict(p.protester.global_position)
		
		if p_district == leader_district:
			protestor_count += 1
			p.set_leader(leader)
			p.change_state(1)
		
	# sort of strict but we can alter as we can form with a minimum crowd size
	if protestor_count >= 1:
		print("DEBUG: INITIATING PROTEST, ALL PROTESTORS WITH LEADER IN DISTRICT ", leader_district)
		return true
		
	return false

func start_protest():
	print("DEBUG: Beginning protest")
	var drone = get_tree().get_first_node_in_group("drone")
	drone.leader_body = leader
	
	emit_signal("protest_started", leader_district)

func disperse_protest():
	print("DEBUG: Dispersing protest")
	var drone = get_tree().get_first_node_in_group("drone")
	drone.leader_body = null
	
	var protesters = get_tree().get_nodes_in_group("protester")
	for p in protesters:
		var parent_p = p.get_parent()
		if parent_p.current_district == leader_district:
			parent_p.state = 7
		
	# emit_signal("leader_escaped", leader_district)
			
	#var riot_police = get_tree().get_nodes_in_group("riot_police")
	#for rp in riot_police:
		#if rp.target_leader == self:
			#emit_signal("on_leader_escaped")

func destroy_structure():
	print("DEBUG: Initiating destruction")

	var district = getDistrict(leader.global_position)
	
	if district == -1:
		print("DEBUG: Not in a valid district")
		return
	
	emit_signal("destruction_started", district)

func _on_move_menu_popup_hide() -> void:
	if move_menu_up:
		move_menu.popup()

func _on_powerup_timer_timeout() -> void:
	multiplier -= 2
	print("powerup over")

func _on_note_timer_timeout() -> void:
	note1.hide()
	note2.hide()
