class_name GameCharacter
extends Node2D

const Action = preload("res://scripts/action.gd")
@onready var ai_module: Node = $aiModule
@onready var glow: Sprite2D = $glow
@onready var blood: AnimatedSprite2D = $blood
@onready var animation_player: AnimationPlayer = $sprite/AnimationPlayer
@onready var sprite: Sprite2D = $sprite

signal action_ended

var targets: PackedVector2Array
var target: Vector2
var speed: float = 100
var direction: Vector2
var is_action_proccesing := false
var moving := false
var finish_callback: Callable
var is_ready := false
var anim_direction := "D_"
var anim_variant := 1


@export var char_name := ""
@export var fraction := "neutral"
@export_group("Stats")
@export var max_hp := 100
var hp := max_hp
@export var atack_damage := 10
@export var atack_range := 2
@export var walk_range := 4
@export var max_pa := 10
var pa := max_pa
@export var max_actions := 5

@export_group("AI")
@export var ai_control := false
@export var ai_module_script :GDScript

var actions: Array[Action] = []



func add_action(action:Action) -> bool:
	print(Action.ActionType.keys()[action.type])
	print(action.target)
	print("PA: ", action.points)
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
	return atack_damage

func take_damage(damage) -> void:
	hp -= damage

func is_dead() -> bool:
	return (hp <= 0)

func _init() -> void:
	for i in range(max_actions):
		actions.push_back(Action.new())
	
func play_attack(target: Vector2):
	rotate_to(target - position)
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
	#animated_sprite_2d.play("U_IDLE")
	animation_player.play("U_IDLE")
	if ai_control:
		ai_module.set_script(ai_module_script)

func process(delta: float) -> void:
	if moving:
		if (target - position).length() < 1: 
			position = target
			change_move_target()
		else:
			position += direction * speed * delta 

func change_move_target():
	if targets.size() > 0:
		target = targets[0]
		targets.remove_at(0)
		direction = (target - position).normalized()
		rotate_to(direction)
		animation_player.play(anim_direction + "WALK")
	else:
		moving = false
		animation_player.play(anim_direction + "IDLE")
	scale.x = anim_variant

func add_move_targets(targ):
	targets = targ
	#targets.reverse()
	
func start_moving():
	moving = true
	change_move_target()
	
func play_blood(angle := 0.0):
	blood.visible = true;
	blood.play("S_BLOOD")
	blood.rotation = angle
	
func select():
	glow.visible = true
	
func unselect():
	glow.visible = false


func _on_blood_animation_finished() -> void:
	blood.visible = false
