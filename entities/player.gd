extends CharacterBody2D

<<<<<<< Updated upstream
# Movement constants
const NORMAL_MAX_SPEED: float = 400.0  # Default horizontal speed
var MAX_SPEED: float = 400.0           # Current max speed (can be modified in-game)
var HOVER_MAX_SPEED: float = 500.0     # Max speed while hovering
var DASH_SPEED: float = 900.0 			# Speed while dashing
var HOVER_REGEN: float = 50.0
var HOVER_DRAIN: float = 30.0
const JUMP_VELOCITY: float = -350.0    # Velocity applied for a normal jump
const DOUBLE_JUMP_VELOCITY: float = -600.0  # Velocity applied for a double jump
const AERIAL_ACCELERATION: float = 1200.0   # Acceleration while in air
const TURN_ACCELERATION: float = 3000.0     # Extra acceleration when changing direction mid-air or on ground
const HOVER_ACCELERATION: float = 2200.0   # Acceleration while hovering
const ACCELERATION: float = 1200.0         # Default acceleration
const HOVER_FRICTION: float = 3000.0       # Friction applied when hovering and no input
const FRICTION: float = 3500.0             # Friction applied on the ground
=======
# -------------------
# Movement Constants
# -------------------
const NORMAL_MAX_SPEED: float = 400.0      # Maximum speed on the ground
var MAX_SPEED: float = 400.0               # Current maximum speed (can change dynamically)
var HOVER_MAX_SPEED: float = 500.0         # Maximum speed while hovering
const JUMP_VELOCITY: float = -350.0        # Initial jump velocity
const DOUBLE_JUMP_VELOCITY: float = -500.0 # Initial double jump velocity
const AERIAL_ACCELERATION: float = 1200.0  # Acceleration while in the air
const TURN_ACCELERATION: float = 3000.0    # Acceleration when changing direction quickly
const HOVER_ACCELERATION: float = 2200.0   # Acceleration while hovering
const ACCELERATION: float = 1200.0         # Standard ground acceleration
const HOVER_FRICTION: float = 3000.0       # Deceleration when hovering without input
const FRICTION: float = 2000.0             # Deceleration when on the ground without input
>>>>>>> Stashed changes

# -------------------
# Gravity Settings
# -------------------
@export var base_gravity: float = 1000.0   # Gravity when on ground or jumping normally
@export var falling_gravity: float = 2000.0# Gravity applied when falling
@export var hover_gravity: float = 0.0     # Gravity applied while hovering
var gravity: float = base_gravity          # Current gravity

# -------------------
# Jump Mechanics
# -------------------
var jump_buffer: float = 0.01              # Timer for buffered jump input
var buffer_time: float = 0.1               # Maximum time for jump buffer
var coyote_time: float = 0.0               # Timer for coyote time (jump after leaving platform)
var added_coyote_time: float = 0.09        # Extra coyote time
var jump_timer: float = 0.0                # Timer for holding jump to control jump height
var max_jump_hold: float = 0.2             # Maximum time jump can be held for higher jump
var has_double_jumped: bool = false        # Tracks if player has double jumped
var is_jumping: bool = false               # Tracks if player is in a jump
var has_jumped: bool = false               # Tracks if player has jumped once
var hovering: bool = false                 # Tracks if player is currently hovering
var has_triple_jumped: bool = false        # Reserved for potential future triple jump

# -------------------
# Player States
# -------------------
enum States {IDLE, JUMPING, FALLING, ON_GROUND, HOVERING} # Movement states
var state: States = States.IDLE            # Current state

<<<<<<< Updated upstream
# Dash variables
var is_dashing: bool = false
var dash_time: float = 0.3
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_speed: float = 900.0


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
=======
# -------------------
# Player Data
# -------------------
@export var data = {
>>>>>>> Stashed changes
	"max_health": 100,
	"health": 100,
	"hover": 100,
}

<<<<<<< Updated upstream
## -----START COMBAT THINGS-----
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

## -----END COMBAT THINGS-----

# State handlers
=======
# Dictionary mapping states to their handler functions
>>>>>>> Stashed changes
var state_handlers := {}

# -------------------
# Initialization
# -------------------
func _ready():
<<<<<<< Updated upstream
=======
	# Map each state to its respective "enter state" function
>>>>>>> Stashed changes
	state_handlers = {
		States.IDLE: _enter_idle,
		States.JUMPING: _enter_jumping,
		States.FALLING: _enter_falling,
		States.ON_GROUND: _enter_on_ground,
		States.HOVERING: _enter_hovering,
	}
	hud.show()

<<<<<<< Updated upstream
func set_state(new_state) -> void:
	last_state = state
=======
# -------------------
# State Handling
# -------------------
func set_state(new_state) -> void:
	var previous_state := state
>>>>>>> Stashed changes
	state = new_state
	if state_handlers.has(state):
		state_handlers[state].call()

<<<<<<< Updated upstream
func _enter_idle(): gravity = base_gravity
func _enter_jumping(): gravity = base_gravity
func _enter_on_ground(): gravity = base_gravity
func _enter_falling(): gravity = falling_gravity
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

=======
# Called when entering IDLE state
func _enter_idle():
	gravity = base_gravity

# Called when entering JUMPING state
func _enter_jumping():
	gravity = base_gravity

# Called when entering ON_GROUND state
func _enter_on_ground():
	gravity = base_gravity

# Called when entering FALLING state
func _enter_falling():
	gravity = falling_gravity

# Called when entering HOVERING state
func _enter_hovering():
	gravity = 0               # Cancel gravity while hovering
	velocity.y = 0            # Stop vertical velocity
	is_jumping = false        # Reset jump state

# -------------------
# Jump Functions
# -------------------
>>>>>>> Stashed changes
func do_jump():
	set_state(States.JUMPING)
	velocity.y = JUMP_VELOCITY  # Apply jump velocity
	is_jumping = true
	has_jumped = true
	jump_timer = 0.0             # Reset jump hold timer
	jump_buffer = 0.0            # Clear buffered jump input

func do_double_jump():
	set_state(States.JUMPING)
	velocity.y = DOUBLE_JUMP_VELOCITY # Apply double jump velocity
	is_jumping = true
	has_double_jumped = true
	jump_timer = 0.0
	jump_buffer = 0.0

<<<<<<< Updated upstream
# --------------------------
# DASH SYSTEM 
# --------------------------


func do_dash():
	is_dashing = true
	dash_timer = dash_time
	dash_direction = (get_global_mouse_position() - global_position).normalized()
	gravity = 0
	velocity = Vector2.ZERO

# HUD updates
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
=======
# -------------------
# Physics and Movement
# -------------------
var hover_activated: bool = false  # Tracks whether hover has been triggered after double jump
>>>>>>> Stashed changes

func _physics_process(delta: float) -> void:
	# -------------------
	# INPUT
	# -------------------
	var input_x = Input.get_axis("ui_left", "ui_right")
	var input_y = Input.get_axis("ui_up", "ui_down")
	var move_vec = Vector2(input_x, input_y)

<<<<<<< Updated upstream
	# Testing buttons
	if Input.is_action_just_pressed("reset"):
		get_tree().call_deferred("reload_current_scene")
	if Input.is_action_just_pressed("test_damage"):
		take_damage(10)

	# DASH INPUT
	if Input.is_action_just_released("dash") and not is_dashing:
		do_dash()

	## -----START COMBAT THINGS-----
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


	# -------------------------
	# DASHING LOGIC
	# -------------------------
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

	# Hovering
	if state == States.HOVERING:
		data.hover -= HOVER_DRAIN * delta
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
=======
	# -------------------
	# HOVER STATE
	# -------------------
	if state == States.HOVERING:
		# Allow free directional movement while hovering
		if move_vec.length() > 0:
			move_vec = move_vec.normalized()
			var target_vel = move_vec * HOVER_MAX_SPEED
			velocity = velocity.move_toward(target_vel, HOVER_ACCELERATION * delta)
		else:
			# Apply friction when no input
			velocity = velocity.move_toward(Vector2.ZERO, HOVER_FRICTION * delta)

		# Exit hover when pressing jump
		if Input.is_action_just_pressed("ui_accept"):
			set_state(States.FALLING)

	# -------------------
	# NORMAL MOVEMENT (GROUND / AIR)
	# -------------------
	else:
		var direction = input_x
		var target_speed = direction * MAX_SPEED
		var accel = ACCELERATION

		# Turning acceleration
		if direction != 0 and sign(direction) != sign(velocity.x) and velocity.x != 0:
			accel = TURN_ACCELERATION
			MAX_SPEED = NORMAL_MAX_SPEED

		# Ground movement
		if is_on_floor():
			if direction != 0:
				velocity.x = move_toward(velocity.x, target_speed, accel * delta)
>>>>>>> Stashed changes
			else:
				velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		# Air movement
		else:
			var air_accel = AERIAL_ACCELERATION
			if direction != 0 and sign(direction) != sign(velocity.x) and velocity.x != 0:
				air_accel = TURN_ACCELERATION
			if direction != 0:
				velocity.x = move_toward(velocity.x, target_speed, air_accel * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, (AERIAL_ACCELERATION * 0.35) * delta)

<<<<<<< Updated upstream
			velocity = velocity.move_toward(move_vec, HOVER_ACCELERATION * delta)
			momentum = velocity
		move_and_slide()
		return

	# Jump buffer
=======
	# -------------------
	# VERTICAL MOVEMENT & GRAVITY
	# -------------------
	if state != States.HOVERING:
		if not is_on_floor():
			# Going up
			if velocity.y < 0:
				if is_jumping and Input.is_action_pressed("ui_accept") and jump_timer < max_jump_hold:
					velocity.y += gravity * 0.3 * delta
					jump_timer += delta
				else:
					velocity.y += falling_gravity * delta
					is_jumping = false
			# Falling
			else:
				if coyote_time <= 0.0:
					velocity.y += falling_gravity * delta
					set_state(States.FALLING)
		else:
			# Reset jump states on ground
			is_jumping = false
			has_jumped = false
			has_double_jumped = false
			hovering = false
			coyote_time = added_coyote_time
			hover_activated = false  # Reset hover flag when landing

	# -------------------
	# JUMP BUFFER & COYOTE TIME
	# -------------------
>>>>>>> Stashed changes
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer = buffer_time
	elif jump_buffer > 0:
		jump_buffer -= delta

<<<<<<< Updated upstream
	# Horizontal movement
	var target_speed = input_x * MAX_SPEED
	var accel = ACCELERATION

	if input_x != 0 and sign(input_x) != sign(velocity.x) and velocity.x != 0:
		accel = TURN_ACCELERATION
		MAX_SPEED = NORMAL_MAX_SPEED

	if is_on_floor():
		if not state == States.HOVERING and data.hover < 100:
			data.hover += HOVER_REGEN * delta
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

	if not is_on_floor() and coyote_time > 0:
		coyote_time -= delta

	if jump_buffer > 0:
=======
	if not is_on_floor() and coyote_time > 0:
		coyote_time -= delta

	# -------------------
	# HANDLE JUMPS
	# -------------------
	if jump_buffer > 0 and state != States.HOVERING:
		# Normal jump
>>>>>>> Stashed changes
		if (is_on_floor() or coyote_time > 0) and not has_jumped:
			do_jump()
			coyote_time = 0.0
		# Double jump
		elif (not is_on_floor() or coyote_time > 0) and not has_double_jumped:
			do_double_jump()
			coyote_time = 0.0
<<<<<<< Updated upstream
		elif not is_on_floor() and has_double_jumped and not hovering and data.hover > 10:
=======
			hover_activated = false  # reset hover flag after double jump
		# Enter hover after double jump (only once)
		elif not is_on_floor() and has_double_jumped and not hover_activated:
>>>>>>> Stashed changes
			set_state(States.HOVERING)
			velocity = Vector2.ZERO
			jump_buffer = 0
			is_jumping = false
			hover_activated = true

<<<<<<< Updated upstream
=======
	# Stop jump when releasing button
>>>>>>> Stashed changes
	if Input.is_action_just_released("ui_accept"):
		jump_timer = max_jump_hold
		is_jumping = false

<<<<<<< Updated upstream
=======
	# -------------------
	# SCENE RESET
	# -------------------
	if Input.is_action_just_pressed("reset"):
		get_tree().call_deferred("reload_current_scene")

	# -------------------
	# APPLY MOVEMENT
	# -------------------
>>>>>>> Stashed changes
	move_and_slide()
