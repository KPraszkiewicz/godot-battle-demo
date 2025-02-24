class_name Action

enum ActionType {
	NONE,
	MOVE,
	ATACK
}

var type : ActionType= ActionType.NONE
var target := Vector2.ZERO
var points := 0



static func get_copy(action: Action) -> Action:
	var a := Action.new()
	a.type = action.type
	a.target = action.target
	a.points = action.points
	return a

static func get_action_name(action: ActionType):
	return ActionType.keys()[action] #TODO: Dodanie lokalizacji

static func get_action_full_string(action: Action):
	return "%s %d (%d,%d)" % [ get_action_name(action.type), action.points, action.target.x,  action.target.y]
