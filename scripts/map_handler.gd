extends Node2D

@onready var turn_system: TurnSystem = %Turn_system
@onready var attack_system: AttackSystem = %Attack_system
@onready var enemy_stats_panel: PanelContainer = %EnemyStatsPanel
@onready var player_actions_panel: PanelContainer = %PlayerActionsPanel
@onready var ally_stats_panel: PanelContainer = %AllyStatsPanel
@onready var movement_system: MovementSystem = %Movement_system


@onready var map: Map = %Map


func clear_map() -> void:
	if map:
		map.queue_free()

func load_map(path) -> void:
	clear_map()
	map = load(path).instantiate()

	map.turn_system = turn_system
	map.attack_system = attack_system
	map.enemy_stats_panel = enemy_stats_panel
	map.player_actions_panel = player_actions_panel
	map.ally_stats_panel = ally_stats_panel
	map.movement_system = movement_system
	
	add_child(map,true)
	player_actions_panel.assign(map.player_character)
	ally_stats_panel.assign(map.player_character)
	map.movement_system.setup_player(map.player_character, map.selected_cell, map.get_grid_position(map.player_character))
	
