class_name Pathfinding
extends TileMapLayer

@onready var ground: TileMapLayer = $"../Ground"

var _obstacles: Array[Vector2i] = []
var astar_grid = AStarGrid2D.new()

func update_movable_cells() -> void:
	var g_rect = ground.get_used_rect()
	
	for x in range(g_rect.position.x, g_rect.position.x + g_rect.size.x):
		for y in range(g_rect.position.y, g_rect.position.y + g_rect.size.y):
			var data := ground.get_cell_tile_data(Vector2(x,y))
			if data and data.get_custom_data("height") == 0:
				astar_grid.set_point_solid(Vector2(x,y), false)
			else:
				astar_grid.set_point_solid(Vector2(x,y), true)
				set_cell(Vector2(x,y))

func is_in_boundsv(v:Vector2i) -> bool:
	return astar_grid.is_in_boundsv(v) and not astar_grid.is_point_solid(v);

func update_obstacles(obstacles: Array[Vector2i]):
	for ob in _obstacles:
		astar_grid.set_point_solid(ob, false)
	for ob in obstacles:
		astar_grid.set_point_solid(ob, true)
	_obstacles = obstacles

func get_path_world(from: Vector2, to: Vector2) -> PackedVector2Array:
	var a = local_to_map(from)
	var b = local_to_map(to)
	if(astar_grid.is_in_boundsv(b)):
		var path = astar_grid.get_point_path(a, b)
		return path
	return []

func get_path_grid(from: Vector2i, to :Vector2i) -> Array[Vector2i]:
	if(astar_grid.is_in_boundsv(to)):
		var path = astar_grid.get_id_path(from, to)
		return path
	return []

func _ready() -> void:
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.offset = Vector2(16, 16)
	astar_grid.jumping_enabled = false
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update()
	update_movable_cells()
