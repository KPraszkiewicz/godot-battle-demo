extends Node

@onready var turn_system: TurnSystem = %Turn_system
@onready var map: Map = %Map
@onready var player_actions_panel: PanelContainer = %PlayerActionsPanel
@onready var ui_turn_queue: HBoxContainer = %UiTurnQueue
@onready var te_actions: TextEdit = %teActions
@onready var gui: CanvasLayer = $Gui
@onready var mid_menu: PanelContainer = %MidMenu

enum GameState {
	IDLE,
	START_TURN,
	WAITING,
	EXECUTING_ACTIONS,
	MOVING,
	END_TURN,
	END_QUEUE,
	END_GAME
}

var gameState := GameState.IDLE

func print_actions():
	te_actions.text = "Tura: %d \n" % turn_system.turn_counter
	#print("Tura: ", turn_system.turn_counter)
	#print("Akcje")
	for i in range(turn_system.actions_it, turn_system.actions_queue.size()):
		var a = turn_system.actions_queue[i]
		te_actions.text += "%s: %s\n" % [a["char"].char_name,Action.get_action_full_string(a["action"])]
	#for a in turn_system.actions_queue:
		#te_actions.text += "%s: %s\n" % [a["char"].char_name,Action.get_action_full_string(a["action"])]
		#print(a["char"].char_name, ": ", Action.get_action_full_string(a["action"]))

func _ready() -> void:
	turn_system.gen_turn_queue()
	gameState = GameState.START_TURN
	print("ready MAIN")
	pass

func change_gameState(new_state):
	print(GameState.keys()[gameState], " -> ", GameState.keys()[new_state])
	gameState = new_state

func _process(_delta: float) -> void:
	gui.update()
	if GameState.START_TURN == gameState:
		turn_system.gen_actions_queue()
		turn_system.sort_actions()
		print_actions()
		
		
		change_gameState(GameState.WAITING)
		
	elif GameState.WAITING == gameState:
		if turn_system.is_all_ready():
			change_gameState(GameState.EXECUTING_ACTIONS)
			turn_system.sort_actions()
			print_actions()
			print("is_all_ready")
		if map.state_waiting == false and false:
			change_gameState(GameState.EXECUTING_ACTIONS)
			print("map.state_waiting")
			
	
	elif GameState.EXECUTING_ACTIONS == gameState:
		print_actions()
		if turn_system.actions_queue_end():
			change_gameState(GameState.END_TURN)
		elif map.is_action_done():
			var ac = turn_system.get_actual_action()
			exec_action(ac["char"], ac["action"])
			turn_system.goto_next_action()
		
	
	elif GameState.END_TURN == gameState:
		if turn_system.check_end_battle():
			print("KONIEC")
			change_gameState(GameState.END_GAME)
		else:
			turn_system.goto_next_turn()
			change_gameState(GameState.START_TURN)
			
	elif GameState.END_GAME == gameState:
		mid_menu.visible = true
		
func exec_action(character: GameCharacter, action: Action):
	print("AKCJA (", character.char_name, "): ", Action.get_action_name(action.type), " TARGET: ", action.target, " PA: ", action.points)
	
	if action.type == Action.ActionType.MOVE:
		map.make_action(character, action)
	elif action.type == Action.ActionType.ATACK:
		map.make_action(character, action)
		#var target = map.get_character(action.target)
		#target.take_damage(character.normal_atack())
		#if target.is_dead():
			#print("Zabito gracza: ", target.char_name)
			#pass
			#target
			#map.remove_character(target)
			#ui_turn_queue.update()
			

func _on_gui_player_actions_confirm() -> void:
	for ch:GameCharacter in %characters.get_children():
		if not ch.ai_control:
			for a:Action in ch.actions:
				if a.type == Action.ActionType.ATACK:
					a.target = map.get_grid_position(map.selectet_char)
			ch.is_ready = true
