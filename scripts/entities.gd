extends Node2D

const PROJECTIVE = preload("res://scenes/projective.tscn")
const ARROW = preload("res://gfx/roguelike-game-kit-pixel-art/1 Characters/Other/Arrow.png")
const FIREBALL = preload("res://gfx/roguelike-game-kit-pixel-art/1 Characters/Other/Fireball.png")

@onready var attack_system: Node = %Attack_system

func spawn_projectile(type, source:Vector2, target: Vector2):
	var proj = PROJECTIVE.instantiate()
	if type == "arrow":
		proj.texture = ARROW
	elif type == "fireball":
		proj.texture = FIREBALL
	proj.position = source
	proj.target = target
	proj.target_reached.connect(attack_system.on_action_end)
	add_child(proj)
