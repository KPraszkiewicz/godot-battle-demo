extends CanvasLayer

signal player_actions_confirm

@onready var ally_stats_panel: PanelContainer = %AllyStatsPanel
@onready var player_actions_panel: PanelContainer = %PlayerActionsPanel


func _on_player_actions_panel_pa_changed() -> void:
	ally_stats_panel.update()

func _on_b_finish_pressed() -> void:
	player_actions_panel.set_actions_to_character()
	player_actions_confirm.emit()

func update():
	ally_stats_panel.update()
	player_actions_panel.update()

func reset():
	#TODO
	pass
