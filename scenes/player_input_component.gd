extends Node

const double_tap_frames := 12

var current_frame := 0

var last_left_press := -9999
var last_right_press := -9999
var gdash_dir := 0.0
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
		
		
		
		
func clear_ground_dash() -> void:
	gdash_dir = 0.0
func wants_ground_dash() -> float:
	var direction = gdash_dir
	gdash_dir = 0.0
	return direction
func get_movement_direction() -> float:
	return Input.get_axis("left", "right") # gives input direction to all states that ask
func wants_jump() -> bool:
	return Input.is_action_just_pressed("up") # same with jump
