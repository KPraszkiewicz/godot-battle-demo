class_name AttackSystem
extends Node

@onready var map_handler: Node2D = %MapHandler
@onready var entities: Node2D = $"../Entities"

var procces_action:Action = null
var action_result:ActionResult = null
var char_source: GameCharacter = null
var char_target: GameCharacter = null

var attack_runnig := false

func exec(character:GameCharacter, action: Action):
	if attack_runnig:
		print("ERROR: [Attack_system::exec] attack_runnig is true")
		return
	attack_runnig = true
	char_source = character
	char_target = map_handler.map.get_character(action.target)
	procces_action = action
	
	if char_target.is_dead():
		char_target = map_handler.map.get_alive_character(char_target.fraction)
		if char_target == null:
			reset()
			return
	
	var result := ActionResult.new()
	result.type = Action.ActionType.ATACK
	
	# Calculate hit chance
	var chance = action.points*0.25 
	
	# hit draw
	if randf() < chance:
		result.hit_target = true
		result.damage = character.attack_damage
	else:
		result.hit_target = false

	action_result = result
	
	entities.spawn_projectile("arrow", character.position, char_target.position)

func on_action_end():
	if not attack_runnig:
		print("ERROR: [Attack_system::anim_end] attack_runnig is false")
		return
	
	if action_result.hit_target:
		char_target.take_damage(action_result.damage)
		char_target.play_blood_from(char_source)
		if char_target.is_dead():
			print("Zabito gracza: ", char_target.char_name)
	
	reset()

func reset():
	procces_action = null
	action_result = null
	char_source = null
	char_target = null
	
	attack_runnig = false
