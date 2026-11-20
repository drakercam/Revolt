extends Node3D

@onready var landscape_tile : PackedScene = preload("res://entities/models/landscape.glb")

@export var size_x : int
@export var size_y : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
