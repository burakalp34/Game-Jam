extends CharacterBody2D

const SPEED := 110.0
const JUMP_VELOCITY := -260.0
const BULLET_SPEED := 350.0

var bullet = preload("res://Scenes/bullet_op.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bulletPosLeft: Node2D = $"shoot_left"
@onready var bulletPosRight: Node2D = $"shoot_right"

func _physics_process(delta: float) -> void:
	# Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saut
	if Input.is_action_just_pressed("jump_op") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Déplacement gauche/droite
	var direction := Input.get_axis("left_op", "right_op")
	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false

	# Animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if Input.is_action_just_pressed("shoot_op"):
		shoot()

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func shoot() -> void:
	
	var piou := bullet.instantiate() 
	get_tree().current_scene.add_child(piou)
	var facing = 0
	
	if animated_sprite.flip_h == true:
		facing = 1
		piou.global_position = bulletPosRight.global_position
	else:
		facing = -1
		piou.global_position = bulletPosLeft.global_position

	piou.apply_impulse(Vector2(BULLET_SPEED * facing, 0), Vector2.ZERO)
