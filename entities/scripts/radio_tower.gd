extends BaseEntity
class_name RadioTower

@onready var global_vars = get_node("/root/global")
@onready var popup_menu: PopupMenu = $"CanvasLayer/PopupMenu"
@onready var district_choice: PopupMenu = $"CanvasLayer/DistrictChoice"
@onready var progress_bar : ProgressBar = $Progress/SubViewport/ProgressBar
@onready var progress_bar_timer : Timer = $Progress/Timer
@onready var propaganda_timer : Timer = $Timers/PropagandaTimer
@onready var note1: ColorRect = $CanvasLayer/Note/NotePt1
@onready var note2: Label = $CanvasLayer/Note/NotePt2
@onready var note_timer: Timer = $Timers/NoteTimer
@onready var intercept_timer : Timer = $Timers/InterceptTimer

var total_morale
var district_id : int = -1

enum {
	SPREAD_PROPAGANDA,
	BOOST_MORALE,
	INTERCEPT_COMMNS,
	TRIGGER_CROWD_FORMING
}

func update_entity(delta):
	update_entity_base(delta)
	# specific update logic here
	
	district_id = global_vars.get_district_from_position(self.global_position)
	
	check_for_drones()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_menu.add_item("Spread the Truth")
	popup_menu.add_item("Boost Protester Morale")
	popup_menu.add_item("Interefere With Drone")
	popup_menu.add_item("Trigger Crowd Forming")
	
	progress_bar.hide()
	progress_bar.value = 0.0
	progress_bar.get_theme_stylebox("fill").bg_color = Color(0.7, 0.0, 0.0, 1.0)
	
	district_choice.add_item("District 1")
	district_choice.add_item("District 2")
	district_choice.add_item("District 3")
	district_choice.add_item("District 4")
	
	total_morale = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_bar.visible:
		progress_bar.value = 100 - (progress_bar_timer.get_time_left() / progress_bar_timer.get_wait_time() * 100)

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		popup_menu.position = Vector2(20, 70)
		popup_menu.size = Vector2(200, 500)
		popup_menu.popup()

func _on_popup_menu_id_pressed(id: int) -> void:
	if (id == SPREAD_PROPAGANDA):
		spread_propaganda()
		
	elif (id == BOOST_MORALE):
		boost_morale()
		
	elif (id == INTERCEPT_COMMNS):
		intercept_comms()
		
	elif (id == TRIGGER_CROWD_FORMING):
		district_choice.position = popup_menu.position
		district_choice.size = popup_menu.size
		district_choice.show()

func check_for_drones():
	if global_vars.surveillance_drone_system.get_size() <= 0:
		return
	
	var drone = global_vars.surveillance_drone_system.get_entity(0)
	
	if global_vars.get_district_from_position(drone.global_position) == district_id:
		progress_bar_timer.paused = true
	else:
		progress_bar_timer.paused = false

func _on_district_choice_id_pressed(id: int) -> void:
	form_crowd(id + 1) # Assumes districts are listed in order

func spread_propaganda()-> void:
	print("Spread Propaganda via Radio Broadcast")
	if !propaganda_timer.is_stopped():
		print("wait for cooldown")
		note1.show()
		note2.text = "Wait For Cooldown"
		note2.show()
		note_timer.start(10.0)
		return
	
	if progress_bar_timer.paused:
		note1.show()
		note2.text = "Drone Interference"
		note2.show()
		note_timer.start(10.0)
		return
	
	var common_people = get_tree().get_nodes_in_group("commoner")
	
	#TODO: make the radio tower's influence depending on how many there are built
	for e in common_people:
		if district_id != e.district_id:
			continue
		print("before dissatisfaction: ", e.getDissatisfactionLevel())
		e.setDissatisfactionLevel(10*global_vars.radio_tower_system.entities.size()) # tweak value
		print("after dissatisfaction: ", e.getDissatisfactionLevel())
	
	propaganda_timer.start(10) # tweek value

func boost_morale()-> void:
	print("Boost Morale")
	#var num_protesters = 20    #for testing
	#total_morale = num_protesters* 10 
	#var wait_time = num_protesters / 10
	total_morale = 20
	var wait_time = 45
	
	progress_bar.show()
	progress_bar.value = 0.0
	progress_bar_timer.start(wait_time)

func timer_paused(p):
	progress_bar_timer.paused = p

func intercept_comms()-> void:
	print("Intercept Comms")
	
	if global_vars.surveillance_drone_system.get_size() <= 0:
		return
	
	var drone = global_vars.surveillance_drone_system.get_entity(0)
	
	if global_vars.get_district_from_position(drone.global_position) == district_id:
		drone.detection_space.hide()
		intercept_timer.start(10.0)
	else:
		note1.show()
		note2.text = "No Drone in Area"
		note2.show()
		note_timer.start(10.0)

func form_crowd(district)-> void:
	print("Trigger Crowd Forming")
	var protesters = get_tree().get_nodes_in_group("protester")
	
	for body in protesters:
		if global_position.distance_to(body.global_position) <= 100 && body.get_parent().state == 0: #TODO: adjust limit
			body.get_parent_node_3d().target_district = district
			body.get_parent_node_3d().state = 4

func _on_timer_timeout() -> void:
	progress_bar.hide()
	progress_bar.value = 0.0
	global_vars.morale += total_morale
	print("new morale = ", global_vars.morale)


func _on_note_timer_timeout() -> void:
	note1.hide()
	note2.hide()


func _on_intercept_timer_timeout() -> void:
	if global_vars.surveillance_drone_system.get_size() <= 0:
		return
	
	var drone = global_vars.surveillance_drone_system.get_entity(0)
	
	drone.detection_space.show()
