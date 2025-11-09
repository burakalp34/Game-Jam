extends RigidBody2D

@export var damage: int = 25
@export var hit_fx: PackedScene = preload("res://Scenes/explosiont.tscn")
@export var shooter: PhysicsBody2D = null

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	if shooter:
		add_collision_exception_with(shooter)
	body_entered.connect(_on_body_entered)

func _on_body_entered(other: Node) -> void:
	if other == shooter:
		return

	var target := other
	if not target.has_method("take_damage") and target.get_parent():
		target = target.get_parent()

	if target.has_method("take_damage"):
		target.take_damage(damage)

	if hit_fx:
		var fx := hit_fx.instantiate()
		get_tree().current_scene.add_child(fx)
		fx.global_position = global_position

	queue_free()
