extends PanelContainer

@export var character_bind: GameCharacter = null
@onready var action_1: Panel = $HBoxContainer/Action1
@onready var action_2: Panel = $HBoxContainer/Action2
@onready var action_3: Panel = $HBoxContainer/Action3
@onready var action_4: Panel = $HBoxContainer/Action4
@onready var action_5: Panel = $HBoxContainer/Action5

signal pa_changed

var pa1 := 0
var pa2 := 0
var pa3 := 0
var pa4 := 0
var pa5 := 0


func _ready() -> void:
	if character_bind:
		update()

func assign(character: GameCharacter) -> void:
	character_bind = character
	update()

func update() -> void:
	pass
	
func reset() -> void:
	pa1 = 0
	pa2 = 0
	pa3 = 0
	pa4 = 0
	pa5 = 0
	action_1.reset()
	action_2.reset()
	action_3.reset()
	action_4.reset()
	action_5.reset()
	
	
func set_actions_to_character() -> void:
	if not character_bind:
		print("WARNING: [set_actions_to_character()] character_bind is null ")
		return
	character_bind.actions[0].type = action_1.action_type
	character_bind.actions[1].type = action_2.action_type
	character_bind.actions[2].type = action_3.action_type
	character_bind.actions[3].type = action_4.action_type
	character_bind.actions[4].type = action_5.action_type

func _on_action_1_clicked_cell(value: int) -> void:
	var dpa = value - pa1
	
	if dpa > character_bind.pa:
		pa1 = character_bind.pa + pa1
		dpa = character_bind.pa
	else:
		pa1 = value
			
	character_bind.pa -= dpa;
	character_bind.actions[0].points = pa1
	action_1.set_value(pa1)
	pa_changed.emit()
	
func _on_action_2_clicked_cell(value: int) -> void:
	var dpa = value - pa2
	
	if dpa > character_bind.pa:
		pa2 = character_bind.pa + pa2
		dpa = character_bind.pa
	else:
		pa2 = value
			
	character_bind.pa -= dpa;
	character_bind.actions[1].points = pa2
	action_2.set_value(pa2)
	pa_changed.emit()

func _on_action_3_clicked_cell(value: int) -> void:
	var dpa = value - pa3
	
	if dpa > character_bind.pa:
		pa3 = character_bind.pa + pa3
		dpa = character_bind.pa
	else:
		pa3 = value
			
	character_bind.pa -= dpa;
	character_bind.actions[2].points = pa3
	action_3.set_value(pa3)
	pa_changed.emit()

func _on_action_4_clicked_cell(value: int) -> void:
	var dpa = value - pa4
	
	if dpa > character_bind.pa:
		pa4 = character_bind.pa + pa4
		dpa = character_bind.pa
	else:
		pa4 = value
		
	character_bind.pa -= dpa;
	character_bind.actions[3].points = pa4
	action_4.set_value(pa4)
	pa_changed.emit()

func _on_action_5_clicked_cell(value: int) -> void:
	var dpa = value - pa5
	
	if dpa > character_bind.pa:
		pa5 = character_bind.pa + pa5
		dpa = character_bind.pa
	else:
		pa5 = value
	
	character_bind.pa -= dpa;
	character_bind.actions[4].points = pa5
	action_5.set_value(pa5)
	pa_changed.emit()


func _on_action_1_changed_type(value: int) -> void:
	character_bind.actions[0].type = value

func _on_action_2_changed_type(value: int) -> void:
	character_bind.actions[1].type = value

func _on_action_3_changed_type(value: int) -> void:
	character_bind.actions[2].type = value

func _on_action_4_changed_type(value: int) -> void:
	character_bind.actions[3].type = value

func _on_action_5_changed_type(value: int) -> void:
	character_bind.actions[4].type = value
