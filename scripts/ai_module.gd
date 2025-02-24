extends Node

@onready var character: GameCharacter = $"."

func get_action(state) -> Action:
	var action := Action.new()
	action.type = Action.ActionType.MOVE
	action.target = state.get_random_point()
	action.points = 2
	return action

func get_actions(state) -> Array[Action]:
	var actions:Array[Action] = []
	actions.push_back(get_action(state))
	var enemy_fraction = "green"
	var enemies = state.get_characters(enemy_fraction)
	
	while actions.size() < 5:
		var action := Action.new()
		action.type = Action.ActionType.ATACK
		action.target = state.get_grid_position(enemies[0])
		action.points = 2
		actions.push_back(action)
	
	return actions
