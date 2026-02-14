extends CharacterBody2D

enum State { IDLE, WALKING, FISHING }
var current_state = State.IDLE

const SPEED = 300.0
var target_position = Vector2.ZERO
var last_direction = "down"
var stop_distance = 5.0
var water_area
var player_near_water = false

@onready var sprite = $AnimatedSprite2D
@onready var fish_data = preload("res://scenes/fish/fish_data.gd").new()

func _ready() -> void:
	target_position = global_position
	water_area = get_node("../map/water")
	
func _input(event):
#	wasd movement
	if current_state == State.IDLE or current_state == State.FISHING:
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			transition_to(State.WALKING)

		
	if current_state == State.IDLE:
		if Input.is_action_just_pressed("fishing"):
			try_fishing()

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle_state()
		State.WALKING:
			handle_walking_state()
		State.FISHING:
			handle_fishing_state()

func handle_idle_state():
	velocity = Vector2.ZERO
	
func handle_walking_state():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction == Vector2.ZERO:
		transition_to(State.IDLE)
		return
		
	var angle = rad_to_deg(input_direction.angle())
	velocity = input_direction * SPEED
	update_animation(angle)
	move_and_slide()
		

func handle_fishing_state():
	velocity = Vector2.ZERO
	
func transition_to(new_state: State):
#	exit previous state
	match current_state:
		State.WALKING:
			velocity = Vector2.ZERO
		State.FISHING:
#			TODO; cancel fishing here
			pass
	
#	enter new state
	current_state = new_state
	
	match new_state:
		State.IDLE:
			play_animation_for_direction(last_direction, "idle")
		State.WALKING:
			pass
		State.FISHING:
#			TODO: add fishing animation here
			pass

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

func _on_water_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_near_water = true
		print("in range")

func _on_water_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_near_water = false
		print("out of range")

func try_fishing():	
	if player_near_water:
		start_fishing()	

func start_fishing():
	transition_to(State.FISHING)
	await get_tree().create_timer(2.0).timeout
	catch_fish()

func catch_fish():
	var fish_names = fish_data.fish_types.keys()
	
	# Pick a random one
	var random_fish = fish_names[randi() % fish_names.size()]

	# Get that fish's info
	var fish_info = fish_data.fish_types[random_fish]
	
	print("Caught a " + random_fish + "!")
	
	# TODO: Add to inventory
	transition_to(State.IDLE)
