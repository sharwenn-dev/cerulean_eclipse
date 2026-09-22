extends State

func enter() -> void:
	player.animation_controller.play_animation("walk")

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y += stats.gravity * delta
		if player.velocity.y >= 0:
			transitioned.emit("fall")
			
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		player.velocity.x = direction * stats.base_move_speed
	else:
		transitioned.emit("idle")
	
	if Input.is_action_just_pressed("up") and player.is_on_floor():
		transitioned.emit("jump")
	
	player.move_and_slide()
