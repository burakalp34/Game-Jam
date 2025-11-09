extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_pressed() -> void:
	var tree := get_tree()
	tree.change_scene_to_file("res://Scenes/start.tscn")

	
