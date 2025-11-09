extends Node2D

@onready var btn: Button = %Star_button

func _ready() -> void:
	btn.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Space.tscn")  # attention à la casse
