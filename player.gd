class_name Player
extends CharacterBody2D
signal defeat
const double_tap_time := 0.2
signal transitioned
var last_left_press := 1.0
var last_right_press := -1.0
@export var stats: PlayerStats
@onready var state_machine: StateMachine = $StateMachine
@onready var mouse_pos = get_global_mouse_position()
@onready var ray: RayCast2D = $RayCast2D
@onready var input_component = $player_input_component
@onready var animation_controller: PlayerAnimationController = $AnimationController
var dead = false

@export var id = "fish"
var manual_save: Dictionary = {}

func _draw() -> void:
	var ray_length: float = lerp(
		25.0,
		250.0,
		clamp(velocity.length() / 500.0, 0.0, 1.0)
	)
	if velocity.length() > 0:
		var direction := velocity.normalized()
		draw_line(
			Vector2.ZERO,
			direction * ray_length,
			Color.RED,
			2.0
		)

func _ready() -> void:
	if not stats:
		stats = PlayerStats.new()
	state_machine.init(self, stats, input_component)
	
func take_damage(damage):
	stats.health -= damage
	if stats.health <= 0 and dead == false:
		dead = true
		stats.health = 0
		defeat.emit(name,Time.get_ticks_msec()) #emit(nameofplayer,timeofdeath)
		

func is_moving_backwards() -> bool:
	if velocity.x == 0.0:
		return false
	
	var moving_dir = sign(velocity.x)
	var mouse_dir = sign(mouse_pos.x - global_position.x)
	
	return moving_dir != mouse_dir

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func _input(event: InputEvent) -> void:
	# test inputs
	if event.is_action_pressed("damageself"):
		take_damage(50)
	
	if event.is_action_pressed("test_rollback"):
		var target_frame = MatchManager.current_frame - 30
		print("Attempting 30 frame rollback from ", MatchManager.current_frame, "to ", target_frame)
		MatchManager.rollback_to(target_frame)
	if event.is_action_pressed("test_save"):
		manual_save = save_state()
		print("State manually SAVED at ", MatchManager.current_frame)
		print("Saved data: ", manual_save)
	if event.is_action_pressed("test_load"):
		if not manual_save.is_empty():
			load_state(manual_save)
			print("State manually LOADED. State: ", state_machine.current_state)
			print(stats.grounded)
		else:
			print("No saved state")

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	stats.grounded = is_on_floor() and velocity.y >= 0
	move_and_slide()
	mouse_pos = get_global_mouse_position()
	queue_redraw()
	input_component.clear_skip_flag()

func save_state() -> Dictionary:
	var player_data = {
		"pos_x": global_position.x,
		"pos_y": global_position.y,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"state": state_machine.current_state,
		"anim_name": animation_controller.animation_player.current_animation,
		"anim_pos": animation_controller.animation_player.current_animation_position
	}
	
	var stats_data = stats.save_stats()
	player_data["stats"] = stats_data
	return player_data

func load_state(data: Dictionary) -> void:
	global_position.x = data["pos_x"]
	global_position.y = data["pos_y"]
	velocity.x = data["velocity_x"]
	velocity.y = data["velocity_y"]
	state_machine.change_state(data["state"], true)
	
	animation_controller.animation_player.play(data["anim_name"])
	animation_controller.animation_player.seek(data["anim_pos"], true)
	
	stats.load_stats(data["stats"])
	
	print("loaded state", state_machine.current_state)
	input_component.skip_next_frame()
