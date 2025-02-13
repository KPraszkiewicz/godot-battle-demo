extends Panel

var unselect_color := Color(0.3,0.3,0.3)
var select_color := Color(0.9, 0.9, 0.9)
var hover_color := Color(0.7,0.7,0.7)

@onready var b1: ColorRect = $CellsContainer/b1
@onready var b2: ColorRect = $CellsContainer/b2
@onready var b3: ColorRect = $CellsContainer/b3
@onready var b4: ColorRect = $CellsContainer/b4
@onready var label: Label = $ActionPanel/ActionLabel

var selected_cells := 0
var action_type : int = Action.ActionType.NONE

signal clicked_cell(value:int)

func _ready() -> void:
	update()

func set_value(pa:int):
	print("set_value", pa)
	selected_cells = pa
	update_cells()

func update():
	update_cells()
	label.text = Action.get_action_name(action_type)

func reset():
	selected_cells = 0
	action_type = Action.ActionType.NONE
	update()

func update_cells(hovered = 0):
	if hovered > 0:
		b1.color = hover_color
		b2.color = hover_color if (hovered > 1) else unselect_color
		b3.color = hover_color if (hovered > 2) else unselect_color
		b4.color = hover_color if (hovered > 3) else unselect_color
	else:
		b1.color = select_color if selected_cells > 0 else unselect_color
		b2.color = select_color if selected_cells > 1 else unselect_color
		b3.color = select_color if selected_cells > 2 else unselect_color
		b4.color = select_color if selected_cells > 3 else unselect_color

func _on_cells_container_mouse_exited() -> void:
	update_cells()

func _on_b1_mouse_entered() -> void:
	update_cells(1)

func _on_b2_mouse_entered() -> void:
	update_cells(2)

func _on_b3_mouse_entered() -> void:
	update_cells(3)

func _on_b4_mouse_entered() -> void:
	update_cells(4)

func _on_b1_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("klik"):
		if selected_cells == 1:
			clicked_cell.emit(0)
		else:
			clicked_cell.emit(1)

func _on_b2_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("klik"):
		if selected_cells == 2:
			clicked_cell.emit(0)
		else:
			clicked_cell.emit(2)

func _on_b3_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("klik"):
		if selected_cells == 3:
			clicked_cell.emit(0)
		else:
			clicked_cell.emit(3)
		
func _on_b4_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("klik"):
		if selected_cells == 4:
			clicked_cell.emit(0)
		else:
			clicked_cell.emit(4)


func _on_action_panel_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("klik"):
		action_type = (action_type+1)%len(Action.ActionType.keys())
		update()
	
