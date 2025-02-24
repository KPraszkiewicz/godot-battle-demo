class_name Map
extends Node2D

const PROJECTIVE = preload("res://scenes/projective.tscn")
const ARROW = preload("res://gfx/roguelike-game-kit-pixel-art/1 Characters/Other/Arrow.png")
const FIREBALL = preload("res://gfx/roguelike-game-kit-pixel-art/1 Characters/Other/Fireball.png")

@onready var characters: Node2D = %characters
@onready var path_line: Line2D = $PathLine
@onready var ground: TileMapLayer = $Ground
@onready var pathfinding: Pathfinding = $Pathfinding
@onready var selected_cell: Sprite2D = $SelectedCell

var turn_system: TurnSystem = null
var attack_system: AttackSystem = null
var movement_system: MovementSystem = null
var enemy_stats_panel: PanelContainer = null
var player_actions_panel: PanelContainer = null
var ally_stats_panel: PanelContainer = null

var player_character: GameCharacter = null
var first_character: GameCharacter = null
var action_runnig := false
var state_waiting := false
var selectet_char: GameCharacter = null


func is_action_done():
	return not (action_runnig or attack_system.attack_runnig)

func _ready() -> void:
	for ch: GameCharacter in characters.get_children():
		if not ch.ai_control:
			player_character = ch
		ch.position = pathfinding.map_to_local(get_grid_position(ch)) 

	print("ready MAP")
	
	selectet_char = characters.get_children()[1]
	first_character = player_character
	update_obstacles(player_character)
	

func _process(_delta: float) -> void:
	if first_character:
		if first_character.ai_control:
			path_line.points = first_character._move_targets
			path_line.points.push_back(first_character.position)
		if action_runnig:
			first_character.process(_delta)
			if not first_character.moving:
				character_end_moving()
		else:
			if not first_character.ai_control:
				var point_click = pathfinding.local_to_map(get_global_mouse_position())
				if get_character(point_click):
					if not get_character(point_click) == first_character:
						path_line.points = [first_character.position, get_character(point_click).position]
				else:
					update_obstacles(player_character)
					var path = pathfinding.get_path_world(first_character.position, get_global_mouse_position())
					path_line.points = path
					#if len(path) > (first_character as GameCharacter).walk_range:
						#path_line.default_color=Color(1,0,0)
					#else:
						#path_line.default_color=Color(0,1,0)



func make_action(character: GameCharacter, action: Action):
	first_character = character
	
	if action.type == Action.ActionType.MOVE:
		update_obstacles(character)
		var path = pathfinding.get_path_world(character.position, pathfinding.map_to_local(action.target))
		character.add_move_targets(path)
		action_runnig = true
		character.start_moving()

func _input(event: InputEvent):
	var point_click = pathfinding.local_to_map(get_global_mouse_position())
	
	if event.is_action_pressed("klik") and is_action_done():
		var target_ch = get_character(point_click)
		if target_ch:
			if not target_ch == player_character:
				enemy_stats_panel.assign(target_ch)
				enemy_stats_panel.update()
				selectet_char.unselect()
				target_ch.select()
				selectet_char = target_ch
				
		elif(pathfinding.is_in_boundsv(point_click)):
			selected_cell.visible = true
			selected_cell.position = get_world_position(point_click)
			movement_system.change_player_move_target(point_click, pathfinding.get_path_grid(get_grid_position(player_character), point_click))
			
	
func character_end_moving():
	print("Koniec ruchu")
	action_runnig = false
	state_waiting = false


##############################################
##############################################
##############################################

func get_path_world(character: GameCharacter, target: Vector2i):
	update_obstacles(character)
	return pathfinding.get_path_world(character.position, pathfinding.map_to_local(target))
	

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

func get_characters(fraction = null) -> Array[GameCharacter]:
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

func get_alive_character(fraction) -> GameCharacter:
	for ch in get_characters(fraction):
		if not ch.is_dead():
			return ch
	return null

func get_alive_enemy_character(ally_fraction) -> GameCharacter:
	for ch in get_characters():
		if ch.fraction != ally_fraction and not ch.is_dead():
			return ch
	return null

func get_world_position(v: Vector2i) -> Vector2:
	return pathfinding.map_to_local(v)

func get_grid_position(node: Node2D):
	return pathfinding.local_to_map(node.position)

func update_obstacles(actual_character = null):
	var chs := characters.get_children()
	var obstacles :Array[Vector2i] = []
	for ch: GameCharacter in chs:
		if ch != actual_character:
			obstacles.push_back(get_grid_position(ch))
		
	pathfinding.update_obstacles(obstacles)
	
