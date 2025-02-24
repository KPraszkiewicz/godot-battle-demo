extends Sprite2D

@export var speed := 200
@export var target := Vector2(0,0)
var source := Vector2(0,0)
var direction := Vector2(0,0)

signal target_reached

func _ready() -> void:
	source = position
	direction = (target - position).normalized()
	rotation = atan2(direction.y, direction.x)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (target - position).dot(direction) < 0:
		visible = false
		target_reached.emit()
		queue_free()
	position += direction * speed * delta
	
