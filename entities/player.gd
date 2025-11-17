extends CharacterBody2D


const SPEED: float = 300.0
const JUMP_VELOCITY: float = -300.0

# YOU CAN FORMAT THESE VARIABLES HOWEVER YOU WANT, IDK HOW THE CLEAN WAY TO DO IT IS
# apparently making your falling gravity more than base makes it feel more snappy. so this is how i did that. also has support if you want to add more for flying or aerial combat.
@export var base_gravity: float = 1000.0
@export var falling_gravity: float = 4000.0
var gravity: float = base_gravity

# jump stuff
var jump_buffer: float = 0.01
var buffer_time: float = 0.5
var coyote_time: float = 0.0
var added_coyote_time: float = 0.09
var jump_timer: float = 0.0
var max_jump_hold: float = 0.2

var is_jumping: bool = false
var has_jumped: bool = false

# probably make a state machine at some point around here
# made the state machine at some point under here V
enum States {IDLE, JUMPING, FALLING, ON_GROUND, HOVERING}
var state: States = States.IDLE

# for now everything other than data and reset is default code for CharacterBody2D
# arrow keys are already replaced with wasd <-- should probably make them custom inputs instead of ui inputs
@export var data = {
	"max_health": 100,
	"health": 100,
	"hover": 100,
}

# dictionary of per-state enter functions
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
	#warning here doesn't matter right now
	var previous_state := state
	state = new_state
	if state_handlers.has(state):
		state_handlers[state].call()

func _enter_idle():
	print("Idle")
	gravity = base_gravity

func _enter_jumping():
	gravity = base_gravity

func _enter_on_ground():
	gravity = base_gravity

func _enter_falling():
	gravity = falling_gravity

func _enter_hovering():
	gravity = 0  # placeholder for hover logic

# JUMP FUNCTION
func do_jump():
	set_state(States.JUMPING)
	velocity.y = JUMP_VELOCITY
	is_jumping = true
	has_jumped = true
	jump_timer = 0.0
	jump_buffer = 0.0

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Add the gravity.
	if not is_on_floor():
		if velocity.y < 0:
			# Only apply variable jump force WHILE ASCENDING
			if is_jumping and Input.is_action_pressed("ui_accept") and jump_timer < max_jump_hold:
				velocity.y += base_gravity * 0.3 * delta
				jump_timer += delta
			else:
				velocity.y += falling_gravity * delta
				is_jumping = false
		else:
			if coyote_time <= 0.0:	
				velocity.y += falling_gravity * delta
				set_state(States.FALLING)
	else:
		# grounded
		is_jumping = false
		has_jumped = false
		coyote_time = added_coyote_time

	#Handle decreasing the jump buffer each frame
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer = buffer_time
	elif jump_buffer > 0:
		jump_buffer -= delta

	#Handle coyote time
	if not is_on_floor() and coyote_time > 0:
		coyote_time -= delta

	# if jump buffer is above zero and player is on the floor then jump
	if jump_buffer > 0 and (is_on_floor() or coyote_time > 0) and not has_jumped:
		do_jump()
		coyote_time = 0.0

	# releasing jump kills variable jump instantly
	if Input.is_action_just_released("ui_accept"):
		jump_timer = max_jump_hold
		is_jumping = false

	# R is reset button for testing
	if Input.is_action_just_pressed("reset"):
		get_tree().call_deferred("reload_current_scene")

	move_and_slide()
