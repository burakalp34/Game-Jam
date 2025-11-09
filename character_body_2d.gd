extends CharacterBody2D

const bulletSpeed = 500
#@onready var player = $CharacterBody2D
var player
@onready var enemie: CharacterBody2D = $"."
@onready var depart_tir: Node2D = $departTire
var bullet = preload("res://Scenes/bullet_op.tscn")
var temps = 2.0

func _ready() -> void:
	player = $"../../CharacterBody2D"

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
	piou.global_position = depart_tir.global_position + ((player.position - enemie.position).normalized() * 10)
	piou.apply_impulse(Vector2(player.position - enemie.position).normalized() * bulletSpeed)
	
	
	
	
	
	
	
	
	
	
