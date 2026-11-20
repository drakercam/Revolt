extends Control
class_name BuildMenu

var revolution_base_scene_path = preload("res://entities/scenes/revolution_base.tscn")
var radio_tower_scene_path = preload("res://entities/scenes/radio_tower.tscn")

@onready var global_vars = get_node("/root/global")
var selected_spot: BuildSpot = null

const BUILD_COSTS = {
	"radio_tower": {"paper": 5, "wood": 5, "ink": 2},
	"revolution_base": {"paper": 10, "wood": 10, "ink": 5}
}

func show_build_menu(spot: BuildSpot):
	selected_spot = spot
	self.visible = true

func build(type: String):
	if selected_spot == null:
		return
		
	var cost = BUILD_COSTS[type]
	
	# check resource count
	if not global_vars.has_resources(cost):
		return
	
	global_vars.spend_resources(cost)
	
	var scene_instance
	if type == "radio_tower":
		scene_instance = radio_tower_scene_path.instantiate()
	elif type == "revolution_base":
		scene_instance = revolution_base_scene_path.instantiate()
		
	scene_instance.global_position = selected_spot.build_position
	selected_spot.get_parent().add_child(scene_instance)

	self.visible = false
	selected_spot = null
