extends CharacterBody2D

enum State { IDLE, WALKING, FISHING }
var current_state = State.IDLE

const SPEED = 300.0
var target_position = Vector2.ZERO
var last_direction = "down"
var stop_distance = 5.0
var water_area
var player_near_water = false
var fishing_timer = null

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
			stop_fishing()
	
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
	fishing_timer = get_tree().create_timer(2.0)
	await fishing_timer.timeout
	
	if fishing_timer != null and current_state == State.FISHING:
		catch_fish()
		
	fishing_timer = null

func stop_fishing():
	fishing_timer = null
	print("fishing cancelled!")

func catch_fish():
	var caught_fish = fish_data.get_random_fish()
	
	print("Caught a " + caught_fish.name + "!")
	show_caught_fish(caught_fish)
	# TODO: Add to inventory
	transition_to(State.IDLE)

func show_caught_fish(fish: Fish):
	var fish_sprite = Sprite2D.new()
	fish_sprite.texture = load(fish.sprite_path)
	fish_sprite.position = global_position + Vector2(0, -50)
	get_tree().root.add_child(fish_sprite)
	
	var tween = create_tween()
	tween.tween_property(fish_sprite, "scale", Vector2(2, 2), 0.4)
	tween.tween_property(fish_sprite, "modulate:a", 0.0, 0.4)

	await tween.finished
	fish_sprite.queue_free()
