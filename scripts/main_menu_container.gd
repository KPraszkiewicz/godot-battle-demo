extends TabContainer

@onready var map_handler: Node2D = %MapHandler
@onready var label: Label = $SelectMapMenu/MarginContainer/VBoxContainer/Label
@onready var main: Node2D = $"../.."

func _ready() -> void:
	get_tree().paused = true
	var button2 := Button.new()
	button2.text = "map2"
	button2.pressed.connect(_on_b_load_map_pressed.bind("res://maps/map2.tscn"))
	label.add_sibling(button2)
	var button1 := Button.new()
	button1.text = "map1"
	button1.pressed.connect(_on_b_load_map_pressed.bind("res://maps/map1.tscn"))
	label.add_sibling(button1)
	
func hide_menu():
	visible = false

func show_EndMenu():
	visible = true
	get_tree().paused = true
	current_tab = 2

func show_SelectMap():
	visible = true
	get_tree().paused = true
	current_tab = 1

func show_MainMenu():
	visible = true
	get_tree().paused = true
	current_tab = 0
	
func _on_b_load_map_pressed(path:String) -> void:
	hide_menu()
	get_tree().paused = false
	map_handler.load_map(path)
	main.reset_game()

func _on_b_quit_pressed() -> void:
	get_tree().quit()
	
func _on_b_to_select_level_pressed() -> void:
	show_SelectMap()

func _on_b_back_pressed() -> void:
	show_MainMenu()
