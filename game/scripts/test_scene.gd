extends Node3D

@onready var popup_menu: PopupMenu = $"CanvasLayer/PopupMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_testcube_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		popup_menu.position = Vector2(20, 70)
		popup_menu.size = Vector2(200, 500)
		popup_menu.popup()

func _on_popup_menu_id_pressed(id: int) -> void:
	if (id == 0):
		print("option 1")
	elif (id == 1):
		print("option 2")
