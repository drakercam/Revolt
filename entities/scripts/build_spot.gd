extends Node3D
class_name BuildSpot

# need reference to the radio tower and revolution base systems
var radio_tower_system : RadioTowerSystem
var revolution_base_system : RevolutionBaseSystem

@onready var popup_menu: PopupMenu = $"CanvasLayer/PopupMenu"
@export var build_position : Vector3

var revolution_base_scene_path = preload("res://entities/scenes/revolution_base.tscn")
var radio_tower_scene_path = preload("res://entities/scenes/radio_tower.tscn")

@onready var global_vars = get_node("/root/global")

const BUILD_COSTS = {
	"radio_tower": {"paper": 20, "wood": 20, "ink": 3},
	"revolution_base": {"paper": 30, "wood": 30, "ink": 8}
}

enum {
	RADIO_TOWER,
	REVOLUTION_BASE
}

func _ready() -> void:
	pass

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		print("DEBUG: BuildSpot clicked!")
		popup_menu.popup()

func _on_popup_menu_id_pressed(id: int) -> void:
	if id == RADIO_TOWER:
		build("radio_tower")
	elif id == REVOLUTION_BASE:
		build("revolution_base")

func build(type: String):
	if type == "":
		return
		
	var cost = BUILD_COSTS[type]
	# check resource count
	if not global_vars.has_resources(cost):
		print("not enough resources")
		return
	
	global_vars.spend_resources(cost)
	
	var scene_instance : BaseEntity
	if type == "radio_tower":
		scene_instance = radio_tower_scene_path.instantiate()
		scene_instance.global_position = Vector3(self.position.x, 0.0, self.position.z)
		scene_instance.scale = Vector3(2.0, 2.0, 2.0)
		scene_instance.rotation = self.rotation
		radio_tower_system.add_entity(scene_instance)
		queue_free()
	elif type == "revolution_base":
		scene_instance = revolution_base_scene_path.instantiate()
		scene_instance.global_position = Vector3(self.position.x, 0.0, self.position.z)
		scene_instance.scale = Vector3(0.5, 0.5, 0.5)
		scene_instance.rotation = self.rotation
		scene_instance.common_people_system = global_vars.common_person_system
		scene_instance.leader_protestor_system = global_vars.leader_protestor_system
		scene_instance.protestor_system = global_vars.protestor_system
		scene_instance.radio_tower_system = radio_tower_system
		revolution_base_system.add_entity(scene_instance)
		queue_free()
			
	#self.visible = false
