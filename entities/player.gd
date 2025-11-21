extends CharacterBody2D

# Movement constants
const NORMAL_MAX_SPEED: float = 400.0   # Default horizontal speed
var MAX_SPEED: float = 400.0            # Current max speed (can be modified in-game)
var HOVER_MAX_SPEED: float = 500.0      # Max speed while hovering
var DASH_SPEED: float = 900.0           # Speed while dashing
const JUMP_VELOCITY: float = -350.0     # Velocity applied for a normal jump
const DOUBLE_JUMP_VELOCITY: float = -600.0  # Velocity applied for a double jump
const AERIAL_ACCELERATION: float = 1200.0   # Acceleration while in air
const TURN_ACCELERATION: float = 3000.0     # Extra acceleration when changing direction mid-air or on ground
const HOVER_ACCELERATION: float = 2200.0   # Acceleration while hovering
const ACCELERATION: float = 1200.0         # Default acceleration
const HOVER_FRICTION: float = 3000.0       # Friction applied when hovering and no input
const FRICTION: float = 3500.0             # Friction applied on the ground

# Gravity settings
@export var base_gravity: float = 1000.0
@export var falling_gravity: float = 2000.0
@export var hover_gravity: float = 0.0
var gravity: float = base_gravity          # Current gravity applied

# Jump buffers and timers
var jump_buffer: float = 0.01              # Tracks buffered jump input
var buffer_time: float = 0.1               # How long a jump input can be stored
var coyote_time: float = 0.0               # Allows jumping shortly after leaving the ground
var added_coyote_time: float = 0.09
var jump_timer: float = 0.0                # Tracks jump hold duration for variable jump height
var max_jump_hold: float = 0.2

# Jump state tracking
var has_double_jumped: bool = false
var is_jumping: bool = false
var has_jumped: bool = false
var hovering: bool = false
var momentum: Vector2 = Vector2.ZERO       # Stores horizontal momentum

# Dash variables
var is_dashing: bool = false
var dash_time: float = 0.25
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_speed: float = 800.0

# HUD elements
@onready var hud = $Camera2D/PlayerHud
@onready var health_bar = $Camera2D/PlayerHud/health_bar
@onready var hover_bar = $Camera2D/PlayerHud/hover_bar

# Player states
enum States {IDLE, JUMPING, FALLING, ON_GROUND, HOVERING}
var state: States = States.IDLE
var last_state: States = state

# Player data
var data = {
	"max_health": 100,
	"health": 100,
	"hover": 100,
}

# --------------------------
# Combat System
# --------------------------
enum CombatState { NEUTRAL, ATTACKING, HITSTUN, ENDLAG }
var combat_state: CombatState = CombatState.NEUTRAL
var attack_index: int = 0
var max_combo: int = 5
var attack_timer: float = 0.0
var attack_reset_time: float = 2
var attack_length: float = 1.5
var endlag_timer: float = 0.0
var endlag_time: float = 1.0
var cooldown_timer: float = 0.0
var cooldown_time: float = 4.0
var hitstun_timer: float = 0.0
var just_attacked: bool = false
var can_attack: bool = true

func attack():
	if combat_state != CombatState.NEUTRAL or not can_attack:
		return
	combat_state = CombatState.ATTACKING
	if attack_index < max_combo:
		attack_index += 1
		attack_timer = attack_reset_time
		print("Attack ", attack_index)
		_activate_hitbox(attack_index)
		just_attacked = true
		if attack_index >= max_combo:
			_start_endlag()

func _start_endlag():
	endlag_timer = endlag_time
	velocity = Vector2.ZERO
	combat_state = CombatState.ENDLAG
	print("ENDLAG")

func reset_combo():
	attack_index = 0
	attack_timer = 0
	if combat_state == CombatState.ATTACKING:
		combat_state = CombatState.NEUTRAL

func apply_hitstun(dur: float):
	hitstun_timer = dur
	velocity = Vector2.ZERO
	combat_state = CombatState.HITSTUN

func _activate_hitbox(index: int):
	print("hitbox active for attack ", index)

# --------------------------
# State Handlers
# --------------------------
var state_handlers := {}

func _ready():
	state_handlers = {
		States.IDLE: _enter_idle,
		States.JUMPING: _enter_jumping,
		States.FALLING: _enter_falling,
		States.ON_GROUND: _enter_on_ground,
		States.HOVERING: _enter_hovering,
	}
	hud.show()

func set_state(new_state) -> void:
	last_state = state
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
	gravity = hover_gravity
	is_jumping = false

func take_damage(amount: int):
	data.health -= amount
	if data.health < 0:
		data.health = 0
	apply_hitstun(1)
	if data.health <= 0:
		get_tree().call_deferred("reload_current_scene")

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

# --------------------------
# Dash System
# --------------------------
func do_dash():
	velocity = Vector2.ZERO
	is_dashing = true
	dash_timer = dash_time
	dash_direction = (get_global_mouse_position() - global_position).normalized()
	gravity = 0
	velocity = Vector2.ZERO

# --------------------------
# HUD Updates
# --------------------------
func _process(_delta: float) -> void:
	if data == null:
		print("DATA WAS NULL — RESETTING")
		data = {
			"max_health": 100,
			"health": 100,
			"hover": 100,
		}
		return
	health_bar.max_value = data["max_health"]
	health_bar.value = data["health"]
	hover_bar.value = data["hover"]

# --------------------------
# Physics & Movement
# --------------------------
func _physics_process(delta: float) -> void:
	# Get player input
	var input_x = Input.get_axis("ui_left", "ui_right")
	var input_y = Input.get_axis("ui_up", "ui_down")

	# Testing buttons
	if Input.is_action_just_pressed("reset"):
		get_tree().call_deferred("reload_current_scene")
	if Input.is_action_just_pressed("test_damage"):
		take_damage(10)

	# DASH INPUT
	if Input.is_action_just_released("dash") and not is_dashing:
		do_dash()

	## -----START COMBAT LOGIC-----
	if combat_state == CombatState.HITSTUN:
		hitstun_timer -= delta
		if hitstun_timer <= 0:
			combat_state = CombatState.NEUTRAL
		move_and_slide()
		return

	if combat_state == CombatState.ENDLAG:
		endlag_timer -= delta
		velocity = Vector2.ZERO
		if endlag_timer <= 0.0:
			combat_state = CombatState.NEUTRAL
			can_attack = false
			reset_combo()
			cooldown_timer = cooldown_time
			return
		move_and_slide()
		return

	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	else:
		if can_attack == false:
			print("REFRESHED!")
			can_attack = true

	if combat_state == CombatState.ATTACKING or just_attacked:
		attack_timer -= delta
		if attack_timer <= attack_length:
			combat_state = CombatState.NEUTRAL
		if attack_timer <= 0:
			just_attacked = false
			reset_combo()
	## -----END COMBAT THINGS-----

# GLOBAL HOVER CANCEL ON GROUND
	if is_on_floor() and state == States.HOVERING:
		set_state(States.ON_GROUND)
		gravity = base_gravity
		hovering = false


	# DASHING LOGIC
	if is_dashing:
		dash_timer -= delta
		var target_velocity = dash_direction * dash_speed
		velocity = velocity.lerp(target_velocity, 0.4)
		move_and_slide()
		if dash_timer <= 0:
			is_dashing = false
			gravity = base_gravity
			if not is_on_floor() and not hovering and data.hover > 10:
				set_state(States.HOVERING)
				jump_buffer = 0
				is_jumping = false
		return

	# HOVERING LOGIC
	if state == States.HOVERING:
		data.hover -= 30 * delta
		if Input.is_action_just_pressed("ui_accept") or data.hover <= 0:
			set_state(States.FALLING)
			gravity = falling_gravity
		else:
			var move_vec = Vector2(input_x, input_y)
			if move_vec.length() == 0:
				if Input.is_action_pressed("ui_accept"):
					move_vec.y = -1
				elif Input.is_action_pressed("ui_down"):
					move_vec.y = 1
			if move_vec.length() > 0:
				HOVER_MAX_SPEED = clamp(HOVER_MAX_SPEED + 5.0 * delta, 500.0, 700.0)
				move_vec = move_vec.normalized() * HOVER_MAX_SPEED
			else:
				move_vec = Vector2.ZERO
				HOVER_MAX_SPEED = 500.0
			velocity = velocity.move_toward(move_vec, HOVER_ACCELERATION * delta)
			momentum = velocity
		move_and_slide()
		return
	# Jump buffer
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer = buffer_time
	elif jump_buffer > 0:
		jump_buffer -= delta

	# Horizontal movement
	var target_speed = input_x * MAX_SPEED
	var accel = ACCELERATION
	if input_x != 0 and sign(input_x) != sign(velocity.x) and velocity.x != 0:
		accel = TURN_ACCELERATION
		MAX_SPEED = NORMAL_MAX_SPEED

	if is_on_floor():
		if not state == States.HOVERING and data.hover < 100:
			data.hover += 15 * delta
			data.hover = min(data.hover, 100)
		if input_x != 0:
			velocity.x = move_toward(velocity.x, target_speed, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		var air_accel = AERIAL_ACCELERATION
		if input_x != 0 and sign(input_x) != sign(velocity.x) and velocity.x != 0:
			air_accel = TURN_ACCELERATION
		if input_x != 0:
			velocity.x = move_toward(velocity.x, target_speed, air_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, momentum.x, (air_accel * 0.5) * delta)

	# Vertical movement & gravity
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
		momentum.x = velocity.x

	# Coyote time decrement
	if not is_on_floor() and coyote_time > 0:
		coyote_time -= delta

	# Handle jumps
	if jump_buffer > 0:
		if (is_on_floor() or coyote_time > 0) and not has_jumped:
			do_jump()
			coyote_time = 0.0
		elif (not is_on_floor() or coyote_time > 0) and not has_double_jumped:
			do_double_jump()
			coyote_time = 0.0
		elif not is_on_floor() and has_double_jumped and not hovering and data.hover > 10:
			set_state(States.HOVERING)
			velocity.y = 0
			jump_buffer = 0
			is_jumping = false

	# Stop jump when releasing button
	if Input.is_action_just_released("ui_accept"):
		jump_timer = max_jump_hold
		is_jumping = false

	# Apply final movement
	move_and_slide()
