extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func pause() -> void:
	get_tree().paused = true
	show()

func resume() -> void:
	get_tree().paused = false
	hide()

func _on_resume_btn_pressed() -> void:
	resume()

func _on_restart_btn_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_menu_btn_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://game/scenes/menu.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
