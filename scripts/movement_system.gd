class_name MovementSystem
extends Node

@onready var map_handler: Node2D = %MapHandler
@onready var main: Node2D = $".."

var action_running := false
var player_character: GameCharacter = null
var player_move_target: Vector2i
var player_move_target_visualization: Node2D = null

var procces_action:Action = null
var char_source: GameCharacter = null

func setup_player(character: GameCharacter, move_target_visualization: Node2D = null, move_target := Vector2i(0,0)):
	player_character = character
	player_move_target = move_target
	player_move_target_visualization = move_target_visualization
	

func change_player_move_target(new_position: Vector2i, path: Array):
	if not player_character:
		print("ERROR: [Movement_system::change_player_move_target] player is null")
	if not map_handler.map:
		print("ERROR: [Movement_system::change_player_move_target] map is null")
		
	main.print_actions()
	player_move_target = new_position
	if path.size() > player_character.get_actual_move_disctance():
		player_move_target_visualization.modulate = Color(1,0,0)
	else:
		player_move_target_visualization.modulate = Color(0,1,0)

func exec(character:GameCharacter, action: Action):
	action_running = true
	char_source = character
	
	var path = map_handler.map.get_path_world(character, action.target)
	
	var char_max_distance := character.walk_speed * action.points
	if char_max_distance == 0:
		reset()
		return
	if path.size() > char_max_distance:
		path.resize(char_max_distance)
		
	character.add_move_targets(path)
	character.start_moving()
	
	if not character.move_ended.is_connected(on_action_end):
		character.move_ended.connect(on_action_end)

#TODO: 
func _process(_delta) -> void:
	if char_source and not char_source.moving:
		on_action_end()

func on_action_end():
	reset()

func reset():
	procces_action = null
	char_source = null
	
	action_running = false
