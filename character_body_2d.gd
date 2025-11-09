extends CharacterBody2D

const bulletSpeed = 500
#@onready var player = $CharacterBody2D
var hp = 25 * mini(4, Data.mondeComp + 1)
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
	
	
	
func take_damage(dmg: int) -> void:
	hp -= dmg
	if hp <= 0:
		die()

func die() -> void:
	get_tree().change_scene_to_file("res://Scenes/ecranmort.tscn")	
	
	
func shoot() -> void:
	var b := bullet.instantiate()
	b.global_position = depart_tir.global_position
	var dir: Vector2 = ((player as Node2D).global_position - depart_tir.global_position).normalized()
	b.linear_velocity = dir * bulletSpeed
	b.shooter = self
	b.add_collision_exception_with(self)
	get_tree().current_scene.add_child(b)

	


	
	
	
	
	
