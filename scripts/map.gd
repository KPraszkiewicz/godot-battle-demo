class_name Map
extends Node2D

const Action = preload("res://scripts/action.gd")
const PROJECTIVE = preload("res://scenes/projective.tscn")
const ARROW = preload("res://gfx/roguelike-game-kit-pixel-art/1 Characters/Other/Arrow.png")
const FIREBALL = preload("res://gfx/roguelike-game-kit-pixel-art/1 Characters/Other/Fireball.png")

@onready var entities: Node2D = $entities
@onready var characters: Node2D = %characters
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var path_line: Line2D = $PathLine
@onready var turn_system: TurnSystem = %Turn_system
@onready var enemy_stats_panel: PanelContainer = %EnemyStatsPanel
@onready var ground: TileMapLayer = $Ground

var player_character: GameCharacter = null
var astar_grid = AStarGrid2D.new()
var first_character: GameCharacter = null
var action_runnig := false
var attack_runnig := false
var state_waiting := false
var selectet_char: GameCharacter = null

func update_movable_cells():
	var g_rect = ground.get_used_rect()
	
	for x in range(g_rect.position.x, g_rect.position.x + g_rect.size.x):
		for y in range(g_rect.position.y, g_rect.position.y + g_rect.size.y):
			var data := ground.get_cell_tile_data(Vector2(x,y))
			if data and data.get_custom_data("height") == 0:
				astar_grid.set_point_solid(Vector2(x,y), false)
			else:
				astar_grid.set_point_solid(Vector2(x,y), true)
				tile_map_layer.set_cell(Vector2(x,y))
				pass

func is_action_done():
	return not (action_runnig or attack_runnig)

func _ready() -> void:
	
	
	astar_grid.region = tile_map_layer.get_used_rect()
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.offset = Vector2(16, 16)
	astar_grid.jumping_enabled = false
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update()
	update_movable_cells()
	
	for ch: GameCharacter in characters.get_children():
		if not ch.ai_control:
			player_character = ch
		ch.position = tile_map_layer.map_to_local(get_grid_position(ch)) 
	
	selectet_char = characters.get_children()[1]
	first_character = player_character
	print("ready MAP")
	
	reset_grid()

func _process(_delta: float) -> void:
	for proj in entities.get_children():
		if proj.target_reached:
			var ch_target = get_character(tile_map_layer.local_to_map(proj.target))
			var ch_source = get_character(tile_map_layer.local_to_map(proj.source))
			ch_target.play_blood(proj.rotation)
			proj.queue_free()
			attack_runnig = false
			ch_target.take_damage(ch_source.normal_atack())
			if ch_target.is_dead():
				print("Zabito gracza: ", ch_target.char_name)
				
	if first_character:
		if first_character.ai_control:
			path_line.points = first_character.targets
		if action_runnig:
			first_character.process(_delta)
			if not first_character.moving:
				character_end_moving()
		else:
			if not first_character.ai_control:
				var point_click = tile_map_layer.local_to_map(get_global_mouse_position())
				if get_character(point_click):
					if not get_character(point_click) == first_character:
						path_line.points = [first_character.position, get_character(point_click).position]
				else:
					var path = get_path_world(first_character.position, get_global_mouse_position())
					path_line.points = path
					if len(path) > (first_character as GameCharacter).walk_range:
						path_line.default_color=Color(1,0,0)
					else:
						path_line.default_color=Color(0,1,0)

func get_grid_position(node: Node2D):
	return tile_map_layer.local_to_map(node.position)

func make_action(character: GameCharacter, action: Action):
	reset_grid()
	first_character = character
	
	if action.type == Action.ActionType.MOVE:
		var path = get_path_world(character.position, tile_map_layer.map_to_local(action.target))
		character.add_move_targets(path)
		action_runnig = true
		character.start_moving()

	if action.type == Action.ActionType.ATACK:
		var target = get_character(action.target)
		character.play_attack(target.position)
		attack_runnig = true
		spawn_projectile("arrow", character.position, target.position)
		


func _input(event: InputEvent):
	var point_click = tile_map_layer.local_to_map(get_global_mouse_position())
	
	if event.is_action_pressed("klik") and is_action_done():
		var target_ch = get_character(point_click)
		if target_ch:
			if not target_ch == player_character:
				enemy_stats_panel.assign(target_ch)
				selectet_char.unselect()
				target_ch.select()
				selectet_char = target_ch
				
		elif(astar_grid.is_in_boundsv(point_click)):
			var action :Action = Action.new()
			action.type = Action.ActionType.MOVE
			action.target = point_click
			#make_action(action)
		

func get_path_world(from, to):
	var a = tile_map_layer.local_to_map(from)
	var b = tile_map_layer.local_to_map(to)
	if(astar_grid.is_in_boundsv(b)):
		var path = astar_grid.get_point_path(a, b)
		return path
	return []

	
func character_end_moving():
	print("Koniec ruchu")
	action_runnig = false
	state_waiting = false

func is_point_empty(point: Vector2i) -> bool:
	for ch in characters.get_children():
		if get_grid_position(ch) == point:
			return false
	return true

func get_random_point():
	var rand_point = Vector2(randi() % 10, randi() % 10)
	
	while not is_point_empty(rand_point):
		rand_point = Vector2(randi() % 10, randi() % 10)
		
	return rand_point

func get_characters(fraction) -> Array[GameCharacter]:
	var result:Array[GameCharacter] = []
	for ch:GameCharacter in characters.get_children():
		if not fraction or  fraction == ch.fraction:
			result.push_back(ch)
			
	return result

func get_character(point: Vector2i) -> GameCharacter:
	for ch in characters.get_children():
		if get_grid_position(ch) == point:
			return ch
	return null

func spawn_projectile(type, source:Vector2, target: Vector2):
	var proj = PROJECTIVE.instantiate()
	if type == "arrow":
		proj.texture = ARROW
	elif type == "fireball":
		proj.texture = FIREBALL
	proj.position = source
	proj.target = target
	entities.add_child(proj)


func reset_grid():
	astar_grid.update()
	var chs = characters.get_children()
	for i in range(chs.size()):
		if i == turn_system.turn_it:
			astar_grid.set_point_solid(get_grid_position(chs[i]), false)
		else:
			astar_grid.set_point_solid(get_grid_position(chs[i]), true)
