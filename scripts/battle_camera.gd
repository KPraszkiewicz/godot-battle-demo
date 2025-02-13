extends Camera2D

# Prędkość poruszania kamerą
@export var speed: float = 200.0

# Mnożnik prędkości przy przytrzymaniu Shift
@export var speed_boost: float = 2.0

# Zoom
@export var zoom_speed: float = 0.1  # Szybkość zoomowania
@export var min_zoom: float = 0.5    # Minimalny zoom
@export var max_zoom: float = 2.0    # Maksymalny zoom

func _process(delta):
	var velocity = Vector2.ZERO

	# Poruszanie kamerą za pomocą klawiszy strzałek lub WASD
	if Input.is_action_pressed("camera_right"):
		velocity.x += 1
	if Input.is_action_pressed("camera_left"):
		velocity.x -= 1
	if Input.is_action_pressed("camera_down"):
		velocity.y += 1
	if Input.is_action_pressed("camera_up"):
		velocity.y -= 1

	# Normalizacja wektora prędkości (aby ruch po skosie nie był szybszy)
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Przyśpieszenie kamery przy przytrzymaniu Shift
	#if Input.is_action_pressed("camera_speed_boost"):
		#velocity *= speed_boost

	# Zoomowanie za pomocą kółka myszy
	if Input.is_action_just_released("camera_zoom_in"):
		zoom_camera(zoom_speed)
	if Input.is_action_just_released("camera_zoom_out"):
		zoom_camera(-zoom_speed)

	# Aktualizacja pozycji kamery
	position += velocity * delta

# Funkcja do obsługi zoomu
func zoom_camera(amount: float):
	var new_zoom = zoom + Vector2(amount, amount)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
