extends State

# this state has movement_locked = true, meaning sprite should not flip if inputs are made during animation
# movement_locked also just means no movement control for the duration of the state besides enter

func enter() -> void:
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))
	# ^^ sets animation speed back to positive so it never plays reversed accidentally
	player.animation_controller.play_animation("dash")
	

func process_physics(delta: float) -> State:
	return null # can go in all directions in the air, if done diagonally down to land will go to running state 
		# no jump canceling air dashes
		# in the future would transition back to flight mode if done from flight mode and fp is above 0
