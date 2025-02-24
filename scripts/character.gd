class_name GameCharacter
extends Node2D

#const Action = preload("res://scripts/action.gd")
@onready var ai_module: Node = $aiModule
@onready var glow: Sprite2D = $glow
@onready var blood: AnimatedSprite2D = $blood
@onready var animation_player: AnimationPlayer = $sprite/AnimationPlayer
@onready var sprite: Sprite2D = $sprite

signal move_ended;

var _move_targets: PackedVector2Array
var _move_target: Vector2
var speed: float = 100
var direction: Vector2
var is_action_proccesing := false
var moving := false
var finish_callback: Callable
var is_ready := false
var anim_direction := "D_"
var anim_variant := 1


var action_target_enemy: Vector2 = Vector2(0,0)
var action_tagret_ally: Vector2 = Vector2(0,0)
var action_target_move: Vector2 = Vector2(0,0)


@export var char_name := ""
@export var fraction := "neutral"
@export_group("Stats")
@export var max_hp := 100
var hp := max_hp
@export var attack_damage := 10
@export var attack_range := 2
@export var walk_speed := 2
@export var max_pa := 10
var pa := max_pa
@export var max_actions := 5

@export_group("AI")
@export var ai_control := false
@export var ai_module_script :GDScript

var actions: Array[Action] = []

func get_actual_move_disctance() -> int:
	var result := 0
	for action in actions:
		if action.type == Action.ActionType.MOVE:
			result += action.points * walk_speed
	return result

func add_action(action:Action) -> bool:
	if actions.size() < max_actions:
		actions.push_back(action)
		return true;
	return false;

func set_actions(new_actions:Array[Action]) -> void:
	if new_actions.size() > max_actions:
		print("ERROR: (set_actions) za dużo akcji")
		return
	actions = new_actions

func normal_atack() -> int:
	return attack_damage

func take_damage(damage) -> void:
	hp -= damage
	if hp <= 0:
		animation_player.play(anim_direction + "DEATH")

func is_dead() -> bool:
	return (hp <= 0)

func _init() -> void:
	for i in range(max_actions):
		actions.push_back(Action.new())
	
func play_attack(target_position: Vector2):
	rotate_to(target_position - position)
	animation_player.play(anim_direction + "ATTACK")

func rotate_to(V: Vector2):
	const UP := Vector2(0,1);
	const LEFT := Vector2(1,0);
	const BORDER := sqrt(2)/2
	var x := UP.dot(V.normalized())
	
	if x > BORDER:
		anim_direction = "D_"
	elif x < -BORDER:
		anim_direction = "U_"
	else:
		anim_direction = "S_"
		if LEFT.dot(V) > 0:
			anim_variant = -1
		else:
			anim_variant = 1
	

func _ready() -> void:
	hp = max_hp
	$Control.tooltip_text = char_name
	#animated_sprite_2d.play("U_IDLE")
	animation_player.play("U_IDLE")
	if ai_control:
		ai_module.set_script(ai_module_script)

func _process(delta: float) -> void:
	if moving:
		if (_move_target - position).length() < 1: 
			position = _move_target
			change_move_target()
		else:
			position += direction * speed * delta 

func change_move_target():
	if _move_targets.size() > 0:
		_move_target = _move_targets[0]
		_move_targets.remove_at(0)
		direction = (_move_target - position).normalized()
		rotate_to(direction)
		animation_player.play(anim_direction + "WALK")
	else:
		moving = false
		animation_player.play(anim_direction + "IDLE")
		move_ended.emit()
	scale.x = anim_variant

func add_move_targets(targ):
	_move_targets = targ
	#_move_targets.reverse()
	
func start_moving():
	moving = true
	change_move_target()
	
func play_blood(angle := 0.0):
	blood.visible = true;
	blood.play("S_BLOOD")
	blood.rotation = angle
	
func play_blood_from(source_char: GameCharacter):
	var v = position - source_char.position
	var angle = atan2(v.y,v.x)
	blood.visible = true;
	blood.play("S_BLOOD")
	blood.rotation = angle

func select():
	glow.visible = true
	
func unselect():
	glow.visible = false


func _on_blood_animation_finished() -> void:
	blood.visible = false
