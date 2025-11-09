extends TileMap

@export var layer := 0
@export var source_id := 0
@export var atlas := Vector2i(0, 0)

@export var width := 180
@export var height := 60

@export var seed := 0
@export_range(0.0, 1.0, 0.01) var fill_chance := 0.54
@export var smooth_steps := 6
@export var wall_threshold := 5
@export var border_wall := true
@export var carve_tunnels := true
@export var tunnel_walkers := 8
@export var tunnel_length := 600
@export_range(0.0, 1.0, 0.05) var tunnel_turn_chance := 0.25
@export var tunnel_width := 1

@export var player_path: NodePath
@export var fallback_global_pos := Vector2(-570, -340)

var _grid: PackedByteArray
var _ox := 0
var _oy := 0

func _ready() -> void:
	generate_around_player()

func _process(_d: float) -> void:
	if Input.is_action_just_pressed("regen_op"):
		generate_around_player()

func _ensure_valid_tile() -> bool:
	if tile_set == null:
		return false
	if not tile_set.has_source(source_id):
		var n := tile_set.get_source_count()
		if n == 0:
			return false
		for i in range(n):
			var sid := tile_set.get_source_id(i)
			if tile_set.has_source(sid):
				source_id = sid
				break
	var src := tile_set.get_source(source_id)
	if src is TileSetAtlasSource:
		var a := src as TileSetAtlasSource
		var ids: Array[Vector2i] = []
		if a.has_method("get_tiles_ids"):
			ids = a.get_tiles_ids()
		else:
			var c := a.get_tiles_count()
			for i in range(c):
				ids.append(a.get_tile_id(i))
		if ids.is_empty():
			return false
		if not ids.has(atlas):
			atlas = ids[0]
	else:
		atlas = Vector2i(0, 0)
	return true

func generate_around_player() -> void:
	if not _ensure_valid_tile():
		return
	var center_cell := _get_center_cell()
	_ox = center_cell.x - width / 2
	_oy = center_cell.y - height / 2

	var rng := RandomNumberGenerator.new()
	if seed != 0:
		rng.seed = seed
	else:
		rng.randomize()


	_grid = PackedByteArray()
	_grid.resize(width * height)
	for y in range(height):
		for x in range(width):
			_grid[y * width + x] = 1 if rng.randf() < fill_chance else 0

	if border_wall:
		for x in range(width):
			_grid[x] = 1
			_grid[(height - 1) * width + x] = 1
		for y in range(height):
			_grid[y * width] = 1
			_grid[y * width + (width - 1)] = 1

	for _i in range(smooth_steps):
		_grid = _step_once(_grid)

	if carve_tunnels:
		_carve_tunnels(rng)

	var c := Vector2i(width / 2, height / 2)
	for yy in range(c.y - 1, c.y + 2):
		for xx in range(c.x - 1, c.x + 2):
			_set_local(xx, yy, 0)
	var by := min(height - 1, c.y + 2)
	_set_local(c.x, by, 1)

	var placed := apply_to_tilemap()
	if placed == 0:
		_force_platform(center_cell)

func _get_center_cell() -> Vector2i:
	var gp := fallback_global_pos
	if not player_path.is_empty():
		var p := get_node_or_null(player_path)
		if p: gp = p.global_position
	var lp := to_local(gp)
	return local_to_map(lp)

func _set_local(x: int, y: int, v: int) -> void:
	if x >= 0 and y >= 0 and x < width and y < height:
		_grid[y * width + x] = v

func _get_local(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height:
		return 1
	return _grid[y * width + x]

func _step_once(g: PackedByteArray) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(g.size())
	for y in range(height):
		for x in range(width):
			var n := 0
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx == 0 and dy == 0: continue
					n += _get_local(x + dx, y + dy)
			var idx := y * width + x
			if g[idx] == 1:
				out[idx] = 1 if n >= wall_threshold else 0
			else:
				out[idx] = 1 if n >= 5 else 0
	return out

func _carve_tunnels(rng: RandomNumberGenerator) -> void:
	var dirs: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for _w in range(tunnel_walkers):
		var p := Vector2i(rng.randi_range(2, width - 3), rng.randi_range(2, height - 3))
		var d := dirs[rng.randi_range(0, dirs.size() - 1)]
		for _s in range(tunnel_length):
			_set_local(p.x, p.y, 0)
			if tunnel_width >= 2:
				var perp := Vector2i(-d.y, d.x)
				_set_local(p.x + perp.x, p.y + perp.y, 0)
			p += d
			if p.x <= 1 or p.y <= 1 or p.x >= width - 2 or p.y >= height - 2:
				break
			if rng.randf() < tunnel_turn_chance:
				d = dirs[rng.randi_range(0, dirs.size() - 1)]

func apply_to_tilemap() -> int:
	clear()
	var count := 0
	for y in range(height):
		for x in range(width):
			if _grid[y * width + x] == 1:
				set_cell(layer, Vector2i(_ox + x, _oy + y), source_id, atlas)
				count += 1
	return count

func _force_platform(center_cell: Vector2i) -> void:
	clear()
	for y in range(-2, 6):
		for x in range(-8, 9):
			set_cell(layer, center_cell + Vector2i(x, y), source_id, atlas)
