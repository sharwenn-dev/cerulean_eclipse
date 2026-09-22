extends State

func enter() -> void:
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))
	# ^^ sets animation speed back to positive so it never plays reversed accidentally
	player.animation_controller.play_animation("jump")
	
	player.velocity.y = stats.jump_force
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		player.velocity.x = direction * stats.base_move_speed
	else:
		player. velocity.x = 0.0

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y += stats.gravity * delta
		if Input.is_action_just_pressed("up") and stats.jumps >= 1:
			stats.jumps -= 1
			transitioned.emit("jump")
		
		# if double input and stats.dashes >= 1:
		#	transitioned.emit("airdash")
		
		if player.velocity.y >= 0:
			transitioned.emit("fall")
	else:
		stats.jumps = stats.max_jumps
		transitioned.emit("idle")
		
			
	player.move_and_slide()
