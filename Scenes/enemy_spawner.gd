extends Node2D

@export var enemy_scene: PackedScene
@export var tilemap_path: NodePath
@export var min_interval := 0.5
@export var max_interval := 0.75
@export var max_enemies := 10
@export var layer := 0

var _tm: TileMap
var _timer := Timer.new()
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_tm = get_node(tilemap_path)
	add_child(_timer)
	_timer.one_shot = true
	_rng.randomize()
	_arm()

func _arm() -> void:
	_timer.start(_rng.randf_range(min_interval, max_interval))
	_timer.timeout.connect(_on_spawn, CONNECT_ONE_SHOT)

func _on_spawn() -> void:
	if enemy_scene and get_tree().get_nodes_in_group("enemies").size() < max_enemies:
		var cells := _tm.get_used_cells(layer)
		if cells.size() > 0:
			var c := cells[_rng.randi_range(0, cells.size() - 1)]
			var above := Vector2i(c.x, c.y - 1)
			var pos := _tm.map_to_local(above)
			var ts := _tm.tile_set
			if ts:
				pos += Vector2(ts.tile_size) * 0.5
			var e := enemy_scene.instantiate()
			e.global_position = _tm.to_global(pos)
			add_child(e)
	_arm()
