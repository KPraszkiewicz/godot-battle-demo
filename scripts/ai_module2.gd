extends Node

const Action = preload("res://scripts/action.gd")

func get_action(state) -> Action:
	var action := Action.new()
	action.type = Action.ActionType.MOVE
	action.target = Vector2(0,0)
	
	return action
