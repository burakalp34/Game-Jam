extends TextureButton

func _pressed() -> void:         # pas besoin de connect()
	var tree := get_tree()
	tree.paused = false
	tree.change_scene_to_file("res://Scenes/start.tscn")
