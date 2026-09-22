extends State

func enter() -> void:
	player.velocity.x = 0.0
	player.animation_controller.play_animation("idle")

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y += stats.gravity * delta
		if player.velocity.y >= 0:
			transitioned.emit("fall")
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		transitioned.emit("walk")
		
	if Input.is_action_just_pressed("up") and player.is_on_floor():
		transitioned.emit("jump")
	
	# if double input and player.is_on_floor():
	#	transitioned.emit("grounddash")
	
	player.move_and_slide()
