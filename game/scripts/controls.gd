extends Control

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"move_up": "Move Forward",
	"move_down": "Move Backward",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"scroll_in": "Zoom In",
	"scroll_out": "Zoom Out",
	"turn_left": "Rotate Left",
	"turn_right": "Rotate Right",
	"pause": "Pause"
}

@onready var labels = $MarginContainer/VBoxContainer.get_children()

@onready var buttons = $MarginContainer2/VBoxContainer.get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_action_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_action_list():
	InputMap.load_from_project_settings()
	
	var i = 1
	
	for action in input_actions:
		labels[i].text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			buttons[i].text = events[0].as_text().trim_suffix(" - Physical")
		else:
			buttons[i].text = ""
		
		buttons[i].pressed.connect(_on_input_button_pressed.bind(buttons[i], action))
		
		i += 1

func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.text = "Press key to bind..."

func _input(event):
	if is_remapping:
		if (
			event is InputEventKey ||
			event is InputEventMouseButton && event.pressed
		):
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()

func _update_action_list(button, event):
	button.text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_btn_pressed() -> void:
	create_action_list()

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/menu.tscn")
