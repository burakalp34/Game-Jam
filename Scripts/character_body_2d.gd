extends CharacterBody2D

var SPEED := 110.0
const JUMP_VELOCITY := -300.0
const BULLET_SPEED := 500.0

const DASH_SPEED := 420.0
const DASH_TIME := 0.12
const DASH_COOLDOWN := 0.35

@export var MAX_HEALTH := 100
var health := MAX_HEALTH
var is_dead := false

@export var MAG_SIZE := 18
@export var RELOAD_TIME := 1.2
var ammo_in_mag := MAG_SIZE
var is_reloading := false
var reload_timer := 0.0

@export var DASH_MAX_CHARGES := 3
@export var DASH_RECHARGE_TIME := 1.5
var dash_charges := DASH_MAX_CHARGES
var dash_recharge_timer := 0.0

var is_dashing := false
var dash_timer := 0.0
var dash_cd := 0.0
var dash_dir := Vector2.ZERO

var bullet = preload("res://Scenes/bullet_op.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bulletPosLeft: Node2D = $"shoot_left"
@onready var bulletPosRight: Node2D = $"shoot_right"
var hud: Node = null

var enemies

func _ready() -> void:
	hud = get_node("../HUDLayer/HUD")
	await get_tree().process_frame
	update_hud()

func _process(delta: float) -> void:
	enemies = get_tree().get_nodes_in_group("Enemy")
	print(len(enemies))


func _physics_process(delta: float) -> void:
	
	if Data.enemie <= 0:
		get_tree().change_scene_to_file("res://Scenes/Space.tscn")
		Data.res()
		Data.inc()
	if dash_cd > 0.0:
		dash_cd -= delta

	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0.0:
			ammo_in_mag = MAG_SIZE
			is_reloading = false
			update_hud()

	if dash_charges < DASH_MAX_CHARGES:
		dash_recharge_timer -= delta
		if dash_recharge_timer <= 0.0:
			dash_charges += 1
			dash_recharge_timer = DASH_RECHARGE_TIME if dash_charges < DASH_MAX_CHARGES else 0.0
			update_hud()

	var direction := Input.get_axis("left_op", "right_op")

	if Input.is_action_just_pressed("dash_op") and not is_dashing and dash_cd <= 0.0 and dash_charges > 0:
		start_dash(direction)

	if not is_dashing and not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("up_op") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		print("")

	if Input.is_action_just_pressed("down_op"):
		velocity.y = -JUMP_VELOCITY

	if Input.is_action_just_pressed("reload_op") and not is_reloading and ammo_in_mag < MAG_SIZE:
		start_reload()

	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false

	if is_dashing:
		dash_timer -= delta
		velocity = dash_dir * DASH_SPEED
		var frames := animated_sprite.sprite_frames
		if frames and frames.has_animation("dash"):
			animated_sprite.play("dash")
		if dash_timer <= 0.0:
			stop_dash()
	else:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")

		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("shoot_op"):
		shoot()

	move_and_slide()

func start_dash(input_dir: float) -> void:
	is_dashing = true
	dash_timer = DASH_TIME
	dash_cd = DASH_COOLDOWN
	dash_charges -= 1
	if dash_charges == DASH_MAX_CHARGES - 1:
		dash_recharge_timer = DASH_RECHARGE_TIME
	update_hud()
	if input_dir == 0.0:
		var facing := 1.0 if animated_sprite.flip_h else -1.0
		dash_dir = Vector2(facing, 0)
	else:
		dash_dir = Vector2(sign(input_dir), 0)
	velocity.y = 0.0

func stop_dash() -> void:
	is_dashing = false

func start_reload() -> void:
	is_reloading = true
	reload_timer = RELOAD_TIME
	update_hud()

func shoot() -> void:
	if is_reloading:
		return
	if ammo_in_mag <= 0:
		start_reload()
		return

	var b := bullet.instantiate()
	var facing := 1 if animated_sprite.flip_h else -1

	if facing == 1:
		b.global_position = bulletPosRight.global_position
	else:
		b.global_position = bulletPosLeft.global_position

	if b is RigidBody2D:
		b.linear_velocity = Vector2(BULLET_SPEED * facing, 0)
		b.shooter = self
		b.add_collision_exception_with(self)

	get_tree().current_scene.add_child(b)

	ammo_in_mag -= 1
	update_hud()


func take_damage(amount:int) -> void:
	if is_dead:
		return
	health -= amount
	update_hud()
	if health <= 0:
		is_dead = true
		# optionnel: désactiver collisions / mouvements
		set_physics_process(false)
		set_process(false)
		# changer de scène après la frame courante
		get_tree().change_scene_to_file("res://ecranmort.tscn") 


func update_hud() -> void:
	if hud:
		if hud.has_method("set_health"): hud.set_health(health, MAX_HEALTH)
		if hud.has_method("set_ammo"):   hud.set_ammo(ammo_in_mag, MAG_SIZE)
		if hud.has_method("set_dash"):   hud.set_dash(dash_charges, DASH_MAX_CHARGES)
