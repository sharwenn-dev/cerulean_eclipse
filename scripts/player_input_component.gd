extends Node

const double_tap_frames := 12

var current_frame := 0

var last_left_press := -9999
var last_right_press := -9999
var gdash_dir := 0.0

var adash_dir := Vector2.ZERO
var last_facing_dir := 1.0

var skip_input_this_frame: bool = false

func _physics_process(delta: float) -> void:
	current_frame += 1
	
	if Input.is_action_just_pressed("left"):
		if current_frame - last_left_press <= double_tap_frames:
			gdash_dir = -1.0
		last_left_press = current_frame
	if Input.is_action_just_pressed("right"):
		if current_frame - last_right_press <= double_tap_frames:
			gdash_dir = 1.0
		last_right_press = current_frame

	var move_axis = Input.get_axis("left", "right")
	if move_axis != 0:
		last_facing_dir = sign(move_axis)
	
	if Input.is_action_just_pressed("dash"):
		var input_vector = Input.get_vector("left", "right", "up", "down")
		if input_vector == Vector2.ZERO:
			adash_dir = Vector2(last_facing_dir, 0.0)
		else:
			adash_dir = input_vector.normalized()

func clear_ground_dash() -> void:
	gdash_dir = 0.0

func clear_air_dash() -> void:
	adash_dir = Vector2.ZERO

func skip_next_frame() -> void:
	skip_input_this_frame = true

func clear_skip_flag() -> void:
	skip_input_this_frame = false

func wants_ground_dash() -> float:
	var direction = gdash_dir
	gdash_dir = 0.0
	return direction

func wants_air_dash() -> Vector2:
	if skip_input_this_frame:
		return Vector2.ZERO
	var direction = adash_dir
	return direction

func find_movement_vector() -> Vector2:
	if skip_input_this_frame:
		return Vector2.ZERO
	var move_vector = Input.get_vector("left", "right", "up", "down")
	return move_vector

func get_movement_direction() -> float:
	if skip_input_this_frame:
		return 0.0
	return Input.get_axis("left", "right") # gives input direction to all states that ask

func wants_jump() -> bool:
	if skip_input_this_frame:
		return false
	return Input.is_action_just_pressed("up") # same with jump

func wants_flight() -> bool:
	if skip_input_this_frame:
		return false
	return Input.is_action_just_pressed("fly")

func wants_down() -> bool:
	if skip_input_this_frame:
		return false
	return Input.is_action_pressed("down") # for fast fall and maybe other things later
