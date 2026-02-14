extends CharacterBody2D

const SPEED = 300.0
var target_position = Vector2.ZERO
var is_moving = false
var last_direction = "down"
var stop_distance = 5.0
var water_area
var is_fishing = false
var player_near_water = false

@onready var sprite = $AnimatedSprite2D
@onready var fish_data = preload("res://scenes/fish/fish_data.gd").new()

func _ready() -> void:
	target_position = global_position
	water_area = get_node("../map/water")
	
func _input(event):
#	for touch
	if event is InputEventScreenTouch and event.pressed:
		target_position = event.position
		is_moving = true
#	for mouse
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_position = get_global_mouse_position()
		is_moving = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F:
		try_fishing()

func _physics_process(delta: float) -> void:
	if is_moving:
		var direction = (target_position - global_position).normalized()
		var distance = global_position.distance_to(target_position)
		
		if distance <= stop_distance:
			is_moving = false
			velocity = Vector2.ZERO
#			keep direction when idle after movement
			play_animation_for_direction(last_direction, "idle")
		else:
			var angle = rad_to_deg(direction.angle())
			velocity = direction * SPEED
			update_animation(angle)
		
		var previous_position = global_position
		move_and_slide()
		
		if global_position.distance_to(previous_position) < 0.1:
#			player is stuck
			is_moving = false
			velocity = Vector2.ZERO
			play_animation_for_direction(last_direction, "idle")

func update_animation(angle: float):
	var result = get_animation_from_angle(angle)
	if result:
		last_direction = result[0]
		var flip_flag = result[1]
		
		sprite.flip_h = flip_flag
		play_animation_for_direction(last_direction, "walk")
	
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
		

func play_animation_for_direction(direction, type):
	var animation = type + "_" + direction
	sprite.play(animation)

func try_fishing():	
	
	if player_near_water:
		#print("fishing")
		start_fishing()
	else:
		print("too far")


func _on_water_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_near_water = true
		print("in range")


func _on_water_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_near_water = false
		print("out of range")

func start_fishing():
	is_fishing = true
	is_moving = false
	velocity = Vector2.ZERO
#	TODO: add fishing animation here

	await get_tree().create_timer(2.0).timeout
	
	catch_fish()

func catch_fish():
	var fish_names = fish_data.fish_types.keys()
	
	# Pick a random one
	var random_fish = fish_names[randi() % fish_names.size()]

	# Get that fish's info
	var fish_info = fish_data.fish_types[random_fish]
	
	print("Caught a " + random_fish + "!")
	print("Rarity: " + str(fish_info["rarity"]))
	print("Value: " + str(fish_info["value"]))
	
	# TODO: Add to inventory
	is_fishing = false
	play_animation_for_direction(last_direction, "idle")
