@tool
extends PanelContainer

@export var character_bind: GameCharacter = null
@export var show_character_name := true
@export var show_hp := true
@export var show_pa := false
@onready var hp_bar: Control = $VBoxContainer/hp_bar
@onready var pa_bar: Control = $VBoxContainer/pa_bar
@onready var char_name: Label = $VBoxContainer/CharName




func _ready() -> void:
	hp_bar.visible = show_hp
	pa_bar.visible = show_pa
	char_name.visible = show_character_name
	
	if character_bind:
		update()

func assign(char: GameCharacter) -> void:
	character_bind = char
	update()

func update() -> void:
	hp_bar.set_values(character_bind.hp, character_bind.max_hp)
	pa_bar.set_values(character_bind.pa, character_bind.max_pa)
	char_name.text = character_bind.char_name
