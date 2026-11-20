extends Control

@onready var global_vars = get_node("/root/global")
@onready var morale_bar = $ProgressBar
@onready var buildings_bar = $ProgressBar2

var MAX_MORALE = 300.0
var MAX_BUILDINGS = 11

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	morale_bar.max_value = MAX_MORALE
	var morale_fill = morale_bar.get_theme_stylebox("fill").duplicate()
	morale_fill.bg_color = Color(0.392, 0.04, 0.0, 1.0)
	morale_bar.add_theme_stylebox_override("fill", morale_fill)
	var morale_bg = morale_bar.get_theme_stylebox("background").duplicate()
	morale_bg.bg_color = Color(0.021, 0.0, 0.496, 1.0)
	morale_bar.add_theme_stylebox_override("background", morale_bg)
	
	buildings_bar.max_value = MAX_BUILDINGS
	var build_fill = buildings_bar.get_theme_stylebox("fill").duplicate()
	build_fill.bg_color = Color(1.0, 0.464, 0.37, 1.0)
	buildings_bar.add_theme_stylebox_override("fill", build_fill)
	var build_bg = buildings_bar.get_theme_stylebox("background").duplicate()
	build_bg.bg_color = Color(0.421, 0.588, 1.0, 1.0)
	buildings_bar.add_theme_stylebox_override("background", build_bg)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	morale_bar.value = global_vars.morale
	buildings_bar.value = MAX_BUILDINGS - global_vars.buildings_left
