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
@onready var player_move_component = $player_input_component
@onready var animation_controller: PlayerAnimationController = $AnimationController
var dead = false
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
	state_machine.init(self, stats, player_move_component)
	
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
	if event.is_action_pressed("damageself"):
		take_damage(50)
	if	event.is_action_pressed("right") or event.is_action_pressed("left"):
		if self.is_on_floor():
			transitioned.emit("gdash")
		else:
			pass
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	move_and_slide()
	mouse_pos = get_global_mouse_position()
	queue_redraw()
