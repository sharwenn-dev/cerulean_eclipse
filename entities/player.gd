extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# YOU CAN FORMAT THESE VARIABLES HOWEVER YOU WANT, IDK HOW THE CLEAN WAY TO DO IT IS
# apparently making your falling gravity more than base makes it feel more snappy. so this is how i did that. also has support if you want to add more for flying or aerial combat.
@export var base_gravity = 1000.0
@export var falling_gravity = 4000.0
var gravity = base_gravity

# jump stuff
var jump_buffer = 0.0
@export var buffer_time = 0.8
var can_coyote = true
var coyote_time = 0.0
var added_coyote_time = 1.0

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

# dictionary of per-state enter functions (removes long if/elif chain)
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
	# warning here that doesn't matter
	var previous_state := state
	state = new_state 
	
	# probably replace this block of elifs with something else, not good enough at godot to know what.
	# (it's replaced now; the comments stay)
	if state_handlers.has(state):
		state_handlers[state].call()

# These still do what your original if/elif blocks did
# you can remove any of these prints if you want
func _enter_idle():
	print("Idle")
	gravity = base_gravity

func _enter_jumping():
	gravity = base_gravity 

func _enter_on_ground():
	gravity = base_gravity

func _enter_falling():
	gravity = falling_gravity
	#Play idle animation or whatever you wanna 

func _enter_hovering():
	gravity = 0  # placeholder for hover logic

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		
		if coyote_time <= 0.0:
			velocity.y += gravity * delta
		
		# checks if velocity is up or down to enable falling def gonna need some reworks with hovering lol
		if velocity.y > 0:
			set_state(States.FALLING)
		#elif velocity.y > 0:

	#Handle decreasing the jump buffer each frame
	# Handle jump.
	# if jump buffer or coyote time is above zero reduce it each frame | probably could make this into the same thing
	if jump_buffer > 0.0:
		jump_buffer -= 5 * delta
	elif coyote_time > 0.0:
		coyote_time -= 5 * delta

	if is_on_floor() and coyote_time <= 0.0:
		coyote_time = added_coyote_time 

	# if jump buffer is above zero and player is on the floor then jump
	if jump_buffer > 0.0 and is_on_floor():
		set_state(States.JUMPING)
		velocity.y = JUMP_VELOCITY
	# coyote jump
	elif not is_on_floor() and coyote_time > 0.0 and jump_buffer > 0.0:
		coyote_time = 0.0
		set_state(States.JUMPING)
		velocity.y = JUMP_VELOCITY

	# set jump buffer on space hit
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer = buffer_time

	# R is reset button for testing
	if Input.is_action_just_pressed("reset"):
		get_tree().call_deferred("reload_current_scene")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
