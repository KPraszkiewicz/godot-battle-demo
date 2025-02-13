@tool
extends Control

@export var internal_label := "HP"
@export var back_color := Color(0.4,0.4,0.4)
@export var front_color :=Color(1,1,1)

@onready var background: ColorRect = $background
@onready var label: Label = $Label
@onready var resizable: ColorRect = $resizable

func _ready() -> void:
	background.color = back_color;
	resizable.color = front_color;
	label.text = internal_label
	resizable.size.y = size.y

func set_values(actual, maximum) ->  void:
	var factor :float = float(actual) / maximum
	
	resizable.size.x = size.x
	resizable.scale.x = factor
	
	#print("FACTOR: ", factor, " ", resizable.size.x, " ", size.x, " ", factor * size.x)
	label.text = internal_label + ": %d/%d" % [actual, maximum]
	
