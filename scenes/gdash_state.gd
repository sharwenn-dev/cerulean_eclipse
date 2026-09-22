extends State

# this state has movement_locked = true, meaning sprite should not flip if inputs are made during animation
# movement_locked also just means no movement control for the duration of the state besides enter

func enter() -> void:
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))
	# ^^ sets animation speed back to positive so it never plays reversed accidentally
	player.animation_controller.play_animation("dash")

func physics_update(delta: float) -> void:
	pass # can only go left or right on the ground, switch to running afterwards if still moving that way
		# ground dash can be cancelled into a jump at a certain point
