extends CharacterBody2D

const SPEED = 300.0
var target_position = Vector2.ZERO
var is_moving = false
var last_direction = "down"
var stop_distance = 5.0

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	target_position = global_position
	
func _input(event):
#	for touch
	if event is InputEventScreenTouch and event.pressed:
		target_position = event.position
		is_moving = true
#	for mouse
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_position = get_global_mouse_position()
		is_moving = true

func _physics_process(delta: float) -> void:
	if is_moving:
		var direction = (target_position - global_position).normalized()
		var distance = global_position.distance_to(target_position)
	
		if distance <= stop_distance:
			is_moving = false
			velocity = Vector2.ZERO
#			keep direction when idle after movement
			var idle_direction = "idle_" + last_direction
			sprite.play(idle_direction)
		else:
			var angle = rad_to_deg(direction.angle())
			velocity = direction * SPEED
			update_animation(angle)
	
		move_and_slide()

func update_animation(angle: float):
	var result = get_animation_from_angle(angle)
	if result:
		last_direction = result[0]
		var flip_flag = result[1]
		
		var animation_name = "walk_" + last_direction
		sprite.flip_h = flip_flag
		sprite.play(animation_name)
	
func get_animation_from_angle(angle):
#	uses angle and return animation name and flip flag
	# Y axis is *FLIPPED*
	if (angle >= -22.5 && angle <= 22.5):
		return ["right", false]
	elif (angle > 22.5 && angle < 67.5):
		return ["ddown", false]
	elif (angle >= 67.5 && angle <= 112.5):
		return ["down", false]
	elif (angle > 112.5 && angle < 157.5):
		return ["ddown", true]
	elif (angle >= 157.5 || angle <= -157.5):
		return ["right", true]
	elif (angle > -157.5 && angle < -112.5):
		return ["dup", true]
	elif (angle >= -112.5 && angle <= -67.5):
		return ["up", false]
	elif (angle > -67.5 && angle < -22.5):
		return ["dup", false]
		
