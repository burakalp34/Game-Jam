extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.get_groups())
	if(area.is_in_group("Asteroid") or area.is_in_group("Space Bullet")):
		area.get_parent().queue_free()
		print("AHHHH STOP SHOOTING ME")
	print("ow...")
