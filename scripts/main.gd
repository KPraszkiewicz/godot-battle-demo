extends Node

@onready var turn_system: TurnSystem = %Turn_system
@onready var movement_system: MovementSystem = $Movement_system
@onready var attack_system: AttackSystem = $Attack_system

@onready var map_handler: Node2D = %MapHandler

@onready var player_actions_panel: PanelContainer = %PlayerActionsPanel
@onready var te_actions: TextEdit = %teActions
@onready var gui: CanvasLayer = $Gui
@onready var main_menu_container: TabContainer = %MainMenuContainer
@onready var ally_stats_panel: PanelContainer = %AllyStatsPanel
@onready var enemy_stats_panel: PanelContainer = %EnemyStatsPanel
@onready var b_finish: Button = $Gui/bFinish

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
	print("ready MAIN")

func change_gameState(new_state):
	print(GameState.keys()[gameState], " -> ", GameState.keys()[new_state])
	gameState = new_state

func reset_game():
	turn_system.gen_turn_queue()
	gameState = GameState.START_TURN

func _process(_delta: float) -> void:
	gui.update()
	if GameState.START_TURN == gameState:
		turn_system.gen_actions_queue()
		turn_system.sort_actions()
		print_actions()
		b_finish.show()
		
		change_gameState(GameState.WAITING)
		
	elif GameState.WAITING == gameState:
		if turn_system.is_all_ready():
			change_gameState(GameState.EXECUTING_ACTIONS)
			turn_system.sort_actions()
			print_actions()
			print("is_all_ready")
		if map_handler.map.state_waiting == false and false:
			change_gameState(GameState.EXECUTING_ACTIONS)
			print("map.state_waiting")
			
	
	elif GameState.EXECUTING_ACTIONS == gameState:
		print_actions()
		if is_action_end():
			if turn_system.actions_queue_end():
				change_gameState(GameState.END_TURN)
			else:
				var ac = turn_system.get_actual_action()
				exec_action(ac["char"], ac["action"])
				turn_system.goto_next_action()
				ally_stats_panel.update()
				enemy_stats_panel.update()
		
	
	elif GameState.END_TURN == gameState:
		if turn_system.check_end_battle():
			print("KONIEC")
			change_gameState(GameState.END_GAME)
		else:
			turn_system.goto_next_turn()
			change_gameState(GameState.START_TURN)
			
	elif GameState.END_GAME == gameState:
		main_menu_container.show_EndMenu()
		
func exec_action(character: GameCharacter, action: Action):
	print("AKCJA (", character.char_name, "): ", Action.get_action_name(action.type), " TARGET: ", action.target, " PA: ", action.points)
	if character.is_dead():
		return
	if action.type == Action.ActionType.MOVE:
		#map_handler.map.make_action(character, action)
		movement_system.exec(character, action)
	elif action.type == Action.ActionType.ATACK:
		attack_system.exec(character, action)

func is_action_end():
	return not movement_system.action_running and not attack_system.attack_runnig

func _on_gui_player_actions_confirm() -> void:
	b_finish.hide()
	for ch:GameCharacter in map_handler.map.get_characters():
		if not ch.ai_control:
			for a:Action in ch.actions:
				if a.type == Action.ActionType.ATACK:
					a.target = map_handler.map.get_grid_position(map_handler.map.selectet_char)
				if a.type == Action.ActionType.MOVE:
					a.target = movement_system.player_move_target
			ch.is_ready = true
