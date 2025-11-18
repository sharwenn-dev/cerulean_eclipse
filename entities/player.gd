extends CharacterBody2D

const MAX_SPEED: float = 300.0
const HOVER_MAX_SPEED: float = 400.0
const JUMP_VELOCITY: float = -350.0
const DOUBLE_JUMP_VELOCITY: float = -650.0
const AERIAL_ACCELERATION: float = 1200.0
const TURN_ACCELERATION: float = 3500.0
const HOVER_ACCELERATION: float = 1200.0
const ACCELERATION: float = 2500.0
const HOVER_FRICTION: float = 3000.0  
const FRICTION: float = 5000.0  

@export var base_gravity: float = 1000.0
@export var falling_gravity: float = 2000.0
@export var hover_gravity: float = 0.0
var gravity: float = base_gravity

var jump_buffer: float = 0.01
var buffer_time: float = 0.1
var coyote_time: float = 0.0
var added_coyote_time: float = 0.09
var jump_timer: float = 0.0
var max_jump_hold: float = 0.2
var has_double_jumped: bool = false
var is_jumping: bool = false
var has_jumped: bool = false
var hovering: bool = false
var has_triple_jumped: bool = false

enum States {IDLE, JUMPING, FALLING, ON_GROUND, HOVERING}
var state: States = States.IDLE

@export var data = {
	"max_health": 100,
	"health": 100,
	"hover": 100,
}

var state_handlers := {}

func _ready():
	state_handlers = {
		States.IDLE: _enter_idle,
		States.JUMPING: _enter_jumping,
		States.FALLING: _enter_falling,
		States.ON_GROUND: _enter_on_ground,
		States.HOVERING: _enter_hovering,
	}

func set_state(new_state) -> void:
	var previous_state := state
	state = new_state
	if state_handlers.has(state):
		state_handlers[state].call()

func _enter_idle():
	gravity = base_gravity

func _enter_jumping():
	gravity = base_gravity

func _enter_on_ground():
	gravity = base_gravity

func _enter_falling():
	gravity = falling_gravity

func _enter_hovering():
	gravity = 0
	velocity.y = 0
	is_jumping = false

func do_jump():
	set_state(States.JUMPING)
	velocity.y = JUMP_VELOCITY
	is_jumping = true
	has_jumped = true
	jump_timer = 0.0
	jump_buffer = 0.0
	
func do_double_jump():
	set_state(States.JUMPING)
	velocity.y = DOUBLE_JUMP_VELOCITY
	is_jumping = true
	has_double_jumped = true
	jump_timer = 0.0
	jump_buffer = 0.0

func _physics_process(delta: float) -> void:
	# HOVER MOVEMENT OVERRIDE
	if state == States.HOVERING:
		if Input.is_action_just_pressed("ui_accept"):
			set_state(States.FALLING)

		var input_x = Input.get_axis("ui_left", "ui_right")
		var input_y = Input.get_axis("ui_up", "ui_down")
		var move_vec = Vector2(input_x, input_y)

		var target_vel = Vector2.ZERO
		if move_vec.length() > 0:
			move_vec = move_vec.normalized()
			target_vel = move_vec * HOVER_MAX_SPEED

		var hover_accel = HOVER_ACCELERATION
		var hover_friction = HOVER_FRICTION

		if move_vec.length() > 0:
			velocity = velocity.move_toward(target_vel, hover_accel * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, hover_friction * delta)

		move_and_slide()
		return

	var direction: float = Input.get_axis("ui_left", "ui_right")
	var target_speed: float = direction * MAX_SPEED
	
	var accel: float = ACCELERATION
	if direction != 0 and sign(direction) != sign(velocity.x) and velocity.x != 0:
		accel = TURN_ACCELERATION
	
	if is_on_floor():
		if direction != 0:
			velocity.x = move_toward(velocity.x, target_speed, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		var air_accel: float = AERIAL_ACCELERATION
		if direction != 0 and sign(direction) != sign(velocity.x) and velocity.x != 0:
			air_accel = TURN_ACCELERATION
		if direction != 0:
			velocity.x = move_toward(velocity.x, target_speed, air_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, (AERIAL_ACCELERATION * 0.35) * delta)

	if not is_on_floor():
		if velocity.y < 0:
			if is_jumping and Input.is_action_pressed("ui_accept") and jump_timer < max_jump_hold:
				if has_double_jumped and not state == States.HOVERING:
					velocity.y += falling_gravity * delta  
					jump_timer += delta
				else:
					velocity.y += gravity * 0.3 * delta
					jump_timer += delta
			else:
				velocity.y += falling_gravity * delta
				is_jumping = false
		else:
			if coyote_time <= 0.0:	
				velocity.y += falling_gravity * delta
				set_state(States.FALLING)
	else:
		is_jumping = false
		has_jumped = false
		has_double_jumped = false
		hovering = false
		coyote_time = added_coyote_time

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer = buffer_time
	elif jump_buffer > 0:
		jump_buffer -= delta

	if not is_on_floor() and coyote_time > 0:
		coyote_time -= delta

	if jump_buffer > 0 and (is_on_floor() or coyote_time > 0) and not has_jumped:
		do_jump()
		coyote_time = 0.0
	elif jump_buffer > 0 and (not is_on_floor() or coyote_time > 0) and not has_double_jumped:
		do_double_jump()
		coyote_time = 0.0
	elif jump_buffer > 0 and not is_on_floor() and has_double_jumped:
		set_state(States.HOVERING)
		velocity.y = 0
		jump_buffer = 0
		is_jumping = false

	if Input.is_action_just_released("ui_accept"):
		jump_timer = max_jump_hold
		is_jumping = false

	if Input.is_action_just_pressed("reset"):
		get_tree().call_deferred("reload_current_scene")

	move_and_slide()
