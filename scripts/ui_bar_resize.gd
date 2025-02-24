@tool
extends Control

@export var internal_label := "HP"
@export var back_color := Color(0.4,0.4,0.4)
@export var front_color :=Color(1,1,1)

@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	var styleBoxBackground = StyleBoxFlat.new()
	var styleBoxFill = StyleBoxFlat.new()
	styleBoxBackground.bg_color = back_color
	styleBoxFill.bg_color = front_color
	progress_bar.add_theme_stylebox_override("background", styleBoxBackground)
	progress_bar.add_theme_stylebox_override("fill", styleBoxFill)

	label.text = internal_label

func set_values(actual, maximum) ->  void:
	label.text = internal_label + ": %d/%d" % [actual, maximum]
	progress_bar.max_value = maximum
	progress_bar.value = actual
	
	
