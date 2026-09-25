extends State

# this state has movement_locked = true, meaning sprite should not flip if inputs are made during animation
# movement_locked also just means no movement control for the duration of the state besides enter

func enter(is_loading: bool = false) -> void:
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))
	player.animation_controller.play_animation("dash")
	movement_locked = true

func process_physics(delta: float) -> State:
	return null
