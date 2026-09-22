extends State


func enter() -> void:
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))
	# ^^ sets animation speed back to positive so it never plays reversed accidentally
	player.animation_controller.play_animation("brake")
func physics_update(delta: float) -> void:
	pass # can transition to basically everything else 
	
	# if double input and player.is_on_floor():
	#	transitioned.emit("grounddash")
