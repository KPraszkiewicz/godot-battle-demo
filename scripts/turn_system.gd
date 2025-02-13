class_name TurnSystem
extends Node

@onready var characters_node: Node2D = %characters
@onready var map: Map = %Map

var turn_queue = []
var turn_it := 0
var actions_queue = []
var actions_it := 0

var turn_counter = 1

func unready_characters():
	for ch in characters_node.get_children():
		ch.is_ready = false

func sort_actions():
	if actions_it != 0:
		print("WARNING: iterator 'actions_it' jest różny od 0 podczas sortowania akcji")
	
	var oi := 0
	var move_queue = []

	for i in range(actions_queue.size()):
		if actions_queue[i]["action"].type == Action.ActionType.MOVE:
			move_queue.push_back(actions_queue[i])
		else:
			actions_queue[oi] = actions_queue[i]
			oi += 1
	
	for ma in move_queue:
		actions_queue[oi] = ma
		oi += 1


func gen_turn_queue() -> void:
	var chs := characters_node.get_children()
	turn_queue.clear()
	for ch in chs:
		turn_queue.push_back(ch)
	turn_it = 0

# SI ustawia akcje na nowo, Gracz musi mieć ustawione akcje przed wywołaniem funkcji
func gen_actions_queue() -> void:
	actions_queue.clear()
	actions_it = 0
	
	for ch:GameCharacter in characters_node.get_children():
		if ch.is_dead():
			continue
		if ch.ai_control and not ch.is_ready:
			ch.set_actions(ch.ai_module.get_actions(map))
			ch.is_ready = true
		for a in ch.actions:
			actions_queue.push_back({"char":ch,"action": a})


func goto_next_turn() -> void:
	gen_turn_queue()
	unready_characters()
	turn_counter += 1
	
func goto_next_character() -> void:
	turn_it += 1
	while(turn_queue.size() < turn_it and not turn_queue[turn_it].is_dead()):
		turn_it += 1
	
func goto_next_action() -> void:
	actions_it += 1
	while(actions_queue.size() < actions_it and not actions_queue[actions_it][0].is_dead()):
		actions_it += 1

func get_actual_character():
	return turn_queue[turn_it]
	
func get_actual_action():
	return actions_queue[actions_it]
	
func is_actual_ai():
	return turn_queue[turn_it].ai_control
	
func is_all_ready() -> bool:
	for ch:GameCharacter in characters_node.get_children():
		if not (ch.is_ready or ch.is_dead()):
			return false
	return true
	
func check_end_battle() -> bool:
	var fractions = {}

	for ch:GameCharacter in characters_node.get_children():
		if not ch.is_dead():
			if ch.fraction in fractions:
				fractions[ch.fraction] += 1
			else:
				fractions[ch.fraction] = 1
	
	if fractions.keys().size() > 1:
		return false
	return true
	
	
func actions_queue_end() -> bool:
	if actions_queue.size() > actions_it:
		return false
	return true
	
func queue_end() -> bool:
	if(turn_queue.size() > turn_it):
		return false
	return true
