extends BaseEntity
class_name RevolutionBase

@onready var popup_menu: PopupMenu = $"CanvasLayer/PopupMenu"
@onready var storage_menu : ColorRect = $CanvasLayer/ColorRect
@onready var paper_label : Label = $CanvasLayer/ColorRect/Label/PaperLabel
@onready var ink_label : Label = $CanvasLayer/ColorRect/Label/InkLabel
@onready var wood_label : Label = $CanvasLayer/ColorRect/Label/WoodLabel
@onready var global_vars = get_node("/root/global") 

# common people have a dissatisfaction level, if its above say 80.0, we convert them
# need to remove the common person from the list
# create a function which acts a roll which will determine if they become a protestor or leader protestor
var common_people_system : CommonPersonSystem
var protestor_system : ProtestorSystem
var leader_protestor_system: LeaderProtestorSystem
var radio_tower_system: RadioTowerSystem

var leader_protestor_scene = preload("res://entities/scenes/leader_protester.tscn")
var protestor_scene = preload("res://entities/scenes/protester.tscn")

var district_id: int = -1

@export var max_protestors = 10
@export var paper_needed = 5
@export var ink_needed = 1
@export var wood_needed = 10 

enum {
	RECRUIT,
	RESOURCE_HANDLING,
	UNIT_HEALING,
	PRINT_NEWSPAPERS,
}

func update_entity(delta):
	update_entity_base(delta)
	# specific update logic here
	
	district_id = global_vars.get_district_from_position(self.global_position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	paper_label.text = "0"
	ink_label.text = "0"
	wood_label.text = "0"
	storage_menu.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	paper_label.text = str(global_vars.tree_paper)
	ink_label.text = str(global_vars.ink)
	wood_label.text = str(global_vars.tree_wood)

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		popup_menu.position = Vector2(20, 70)
		popup_menu.size = Vector2(200, 500)
		popup_menu.popup()


func _on_popup_menu_id_pressed(id: int) -> void:
	if (id == RECRUIT):
		print("Recruitment Component")
		recruit()
		
	elif (id == RESOURCE_HANDLING):
		print("Resource Storage / Accumulation")
		gather_show_resources()
		
	elif (id == UNIT_HEALING):
		print("Unit Healing")
		heal_units()
		
	elif (id == PRINT_NEWSPAPERS):
		print("Spreading propaganda, need resources to do this")
		print_newspapers()

func recruit():
	print("Recruiting")
	print("DEBUG: NUMBER OF COMMON PEOPLE=", common_people_system.get_size())
	if common_people_system.get_entity(0):
		print("Common person dissatisfaction level=", common_people_system.get_entity(0).getDissatisfactionLevel())
	else:
		print("No Common people present")
	
	var convert = []
	
	for i in range(common_people_system.get_size()):
		if common_people_system.get_entity(i).getDissatisfactionLevel() >= 80.0 and common_people_system.get_entity(i).recruit:
			print("Needed Recruitment dissatisfaction level met and can be recruited for common person ", i)
			convert.append(i - convert.size())
	for n in convert:
		convert_to_protestor(n)

func convert_to_protestor(index):
	# TODO: CREATE RANDOM ROLL TO ASSIGN CONVERTED COMMON PERSON TO EITHER LEADER OR REGULAR PROTESTOR
	var current_size = leader_protestor_system.get_size() + protestor_system.get_size()
	if current_size >= max_protestors:
		print("DEBUG: Reached maximum number of protestors allowed")
		return
	
	print("converting person ", index)
	
	if !common_people_system.get_entity(index).passionate:
		# remove the common person from the system
		var prev_position = common_people_system.get_entity(index).position
		common_people_system.erase_entity_at(index)
		print("DEBUG: AFTER REMOVAL, NUMBER OF COMMON PEOPLE=", common_people_system.get_size())
		
		# add a new protestor to the protestor system
		print("DEBUG: BEFORE ADD, NUMBER OF PROTESTOR PEOPLE=", protestor_system.get_size())
		var new_protestor = protestor_scene.instantiate()
		new_protestor.position = prev_position
		protestor_system.add_entity(new_protestor)
		print("DEBUG: AFTER ADD, NUMBER OF PROTESTOR PEOPLE=", protestor_system.get_size())
	else:
		# remove the common person from the system
		var prev_position = common_people_system.get_entity(index).position
		common_people_system.erase_entity_at(index)
		print("DEBUG: AFTER REMOVAL, NUMBER OF COMMON PEOPLE=", common_people_system.get_size())
		
		# add a new leader to the leader_protester system
		print("DEBUG: BEFORE ADD, NUMBER OF LEADER PEOPLE=", leader_protestor_system.get_size())
		var new_leader = leader_protestor_scene.instantiate()
		new_leader.position = prev_position
		new_leader.protestor_system = protestor_system
		new_leader.connect("protest_started", Callable(global_vars.main_gameplay_scene, "_on_protest_started"))
		new_leader.connect("destruction_started", Callable(global_vars.main_gameplay_scene, "_on_destruction_started"))
		new_leader.connect("protest_ended", Callable(self, "_on_protest_ended"))
		leader_protestor_system.add_entity(new_leader)
		print("DEBUG: AFTER ADD, NUMBER OF LEADER PEOPLE=", leader_protestor_system.get_size())
	
	global_vars.recruitable_count -= 1

func gather_show_resources():
	# CAN COMPLETE ONCE WE IMPLEMENT RESOURCES PROPERLY
	# MAYBE SHOWCASE CURRENT RESOURCE COUNT IN A MENU AND ALSO HAVE A BUTTON THAT ALLOWS FOR ACCUMULATION
	# WILL NEED TO OCCUPY PROTESTORS SO CREATED A VARIABLE IN THE PROTESTOR SCRIPT THAT MARKS AS OCCUPIED
	print("Show and Gather Resources Menu")
	for e in protestor_system.entities:
		print("DEBUG: Protestor is occupied=", e.getOccupied())
	storage_menu.show()

func heal_units():
	# TODO: IMPLEMENT SOME SORT OF TIMER WHICH HEALS PER SECOND AND PROVIDE A VISUAL CUE
	# MAYBE REUSE PROGRESS BAR
	for e in protestor_system.entities:
		print("DEBUG: Protestor health=",e.health)
		if (e.health < 100):
			e.health = 100
			print("DEBUG: After heal, Protestor health=",e.health)
		
	for e in leader_protestor_system.entities:
		print("DEBUG: Leader Protestor health=",e.health)
		if (e.health < 100):
			e.health = 100
			print("DEBUG: After heal, Leader Protestor health=",e.health)

func print_newspapers():
	print("Common system:", common_people_system)
	if global_vars.tree_paper < paper_needed or global_vars.ink < ink_needed:
		print("collect materials first")
		return
	
	for e in common_people_system.entities:
		if e.district_id != district_id:
			print("common person district_id=", e.district_id)
			print("base district_id=", district_id)
			continue
		print("before dissatisfaction: ", e.getDissatisfactionLevel())
		e.setDissatisfactionLevel(20) # tweak value
		print("after dissatisfaction: ", e.getDissatisfactionLevel())

	global_vars.tree_paper -= paper_needed
	global_vars.ink -= ink_needed

func _on_collect_button_pressed() -> void:
	print("Initiate Gather Resources")
	for e in protestor_system.entities:
		if !e.occupied && e.state != 3 && e.state != 2 && e.state != 1: # not already collecting
			e.state = 2

func _on_close_button_pressed() -> void:
	storage_menu.hide()
