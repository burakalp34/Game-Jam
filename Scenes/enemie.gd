extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var player = $CharacterBody2D
@onready var enemie: CharacterBody2D = $"."
@onready var enemie_shoot_pos: Node2D = $enemieShootPos
var bullet = preload("res://Scenes/bullet_op.tscn")
var temps = 2.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	temps -= delta
	if temps <= 0:
		shoot()
		temps = 2.0
	move_and_slide()
	
func shoot() -> void:
	var piou := bullet.instantiate()
	get_tree().current_scene.add_child(piou)
	piou.global_position = enemie_shoot_pos.global_position
	piou.apply_impulse(Vector2(player.position - enemie.position), Vector2(enemie.position))
	
	
	
	
	
	
	
	
	
	
