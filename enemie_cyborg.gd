extends CharacterBody2D

@export var speed := 80.0
@export var gravity := 1200.0
@export var jump_velocity := -320.0
@export var tilemap_path: NodePath
@export var fire_cooldown := 0.9
@export var sense_range := 900.0
@export var max_drop := 3
@export var bullet_scene: PackedScene = preload("res://Scenes/bullet_op.tscn")
@export var bullet_speed := 350.0

var _tm: TileMap
var _ts := Vector2i(16, 16)
var _dir := -1
var _fire_cd := 0.0
var _player: Node2D
@onready var _sprite := get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	add_to_group("enemies")
	if not tilemap_path.is_empty():
		_tm = get_node(tilemap_path)
		if _tm and _tm.tile_set:
			_ts = _tm.tile_set.tile_size
	_player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	_move_ai(delta)
	if _fire_cd > 0.0:
		_fire_cd -= delta
	_try_fire()
	move_and_slide()

func _move_ai(_delta: float) -> void:
	if _tm:
		var ahead := global_position + Vector2(_dir * _ts.x * 0.6, 0)
		var foot := ahead + Vector2(0, _ts.y * 0.6)
		var cell_ahead := _tm.local_to_map(_tm.to_local(ahead))
		var cell_foot := _tm.local_to_map(_tm.to_local(foot))
		var drop := _drop_depth(cell_foot)
		var wall := _is_wall(cell_ahead)
		if wall:
			if is_on_floor():
				_try_jump()
			else:
				_dir *= -1
		elif drop > max_drop:
			_dir *= -1
	velocity.x = _dir * speed
	if _sprite:
		_sprite.flip_h = (_dir > 0)

func _is_wall(c: Vector2i) -> bool:
	return _tm.get_cell_source_id(0, c) != -1

func _drop_depth(start_cell: Vector2i) -> int:
	var d := 0
	var c := start_cell
	while d <= 6:
		if _tm.get_cell_source_id(0, c) != -1:
			return d
		d += 1
		c.y += 1
	return d

func _try_jump() -> void:
	var head := global_position + Vector2(0, -_ts.y * 0.9)
	var front := head + Vector2(_dir * _ts.x * 0.9, 0)
	var ch := _tm.local_to_map(_tm.to_local(front))
	if _tm.get_cell_source_id(0, ch) != -1:
		velocity.y = jump_velocity

func _try_fire() -> void:
	if not _player or _fire_cd > 0.0:
		return
	var to_p := _player.global_position - global_position
	if to_p.length() > sense_range:
		return
	var same_row := absf(to_p.y) < float(_ts.y) * 0.6
	var same_col := absf(to_p.x) < float(_ts.x) * 0.6
	if not (same_row or same_col):
		return
	var dir := Vector2.ZERO
	if same_row:
		dir = Vector2(sign(to_p.x), 0)
	elif same_col:
		dir = Vector2(0, sign(to_p.y))
	if bullet_scene:
		var b := bullet_scene.instantiate()
		get_tree().current_scene.add_child(b)
		b.global_position = global_position
		if b.has_method("apply_impulse"):
			b.apply_impulse(dir * bullet_speed, Vector2.ZERO)
		elif b.has_variable("linear_velocity"):
			b.linear_velocity = dir * bullet_speed
	_fire_cd = fire_cooldown
