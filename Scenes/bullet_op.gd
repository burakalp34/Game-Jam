extends RigidBody2D

@export var hit_fx: PackedScene = preload("res://Scenes/explosiont.tscn")  

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_hit) 

func _on_hit(_other: Node) -> void:
	if hit_fx:
		var fx := hit_fx.instantiate()
		get_parent().add_child(fx)
		fx.global_position = global_position
	queue_free()
