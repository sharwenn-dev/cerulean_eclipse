extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# YOU CAN FORMAT THESE VARIABLES HOWEVER YOU WANT, IDK HOW THE CLEAN WAY TO DO IT IS
# apparently making your falling gravity more than base makes it feel more snappy. so this is how i did that. also has support if you want to add more for flying or aerial combat.
@export var base_gravity = 1000.0
@export var falling_gravity = 4000.0
var gravity = base_gravity
# jump buffer stuff
var jump_buffer = 0.0
@export var buffer_time = 0.8
# probably make a state machine at some point around here
# made the state machine at some point under here V
enum States {IDLE,JUMPING,FALLING,ON_GROUND,HOVERING}
var state: States = States.IDLE
# for now everything other than data and reset is default code for CharacterBody2D
# arrow keys are already replaced with wasd <-- should probably make them custom inputs instead of ui inputs
@export var data = {
	"max_health": 100,
	"health": 100,
	"hover": 100,
}
func set_state(new_state) -> void:
	# warning here that doesn't matter
	var previous_state := state
	state = new_state 
	# probably replace this block of elifs with something else, not good enough at godot to know what.
		
	# you can remove any of these prints if you want
	if state == States.IDLE:
		print("State is idle.")
	elif state == States.JUMPING:
		print("Jumping")
		gravity = base_gravity 
		 
	elif state == States.ON_GROUND:
		gravity = base_gravity
	elif state == States.FALLING:
		print("Falling")
		gravity = falling_gravity
		#Play idle animation or whatever you wanna do
func _physics_process(delta: float) -> void:
	# Add the gravity.

	if not is_on_floor():
		velocity.y  += gravity * delta
		
		# checks if velocity is up or down to enable falling def gonna need some reworks with hovering lol
		if velocity.y > 0:
			set_state(States.FALLING)
	
	#Handle decreasing the jump buffer each frame
	
	# Handle jump.
	# if jump buffer is above zero reduce it each frame
	if jump_buffer > 0.0:
		jump_buffer -= 5 * delta
		print(jump_buffer)
	# if jump buffer is above zero and player is on the floor then jump
	if jump_buffer > 0.0 and is_on_floor():
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
	
