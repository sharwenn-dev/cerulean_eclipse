extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# probably make a state machine at some point around here
# for now everything other than data and reset is default code for CharacterBody2D
# arrow keys are already replaced with wasd
@export var data = {
	"max_health": 100,
	"health": 100,
	"hover": 100,
}

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
