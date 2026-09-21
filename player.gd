class_name Player
extends CharacterBody2D
signal defeat
@export var stats: PlayerStats
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_controller: PlayerAnimationController = $AnimationController
@onready var mouse_pos = get_global_mouse_position()

var dead = false

func _ready() -> void:
	if not stats:
		stats = PlayerStats.new()
	state_machine.init(self, stats)
	
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
	state_machine.update(delta)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("damageself"):
		take_damage(50)
		
func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	var direction = Input.get_axis("left", "right")
	mouse_pos = get_global_mouse_position()
	
	velocity.x = direction * stats.base_move_speed

	move_and_slide()
