class_name PlayerAnimationController
extends Node

@export var animation_player: AnimationPlayer
@onready var body_sprite = owner.find_child("Body")
@onready var head_sprite = owner.find_child("Head")
@onready var reticle = owner.find_child("AimHandler")

@export var head_offset = 15

func play_animation(anim_name: String) -> void:
	if animation_player and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func set_facing_direction() -> void:
	if owner.has_node("Body"):
	#	var direction := Input.get_axis("left", "right")
	#	if direction != 0:
	#		body_sprite.flip_h = direction < 0
		var mouse_pos = owner.get_global_mouse_position()
		if mouse_pos.x > owner.position.x:
			body_sprite.flip_h = false
		elif mouse_pos.x < owner.position.x:
			body_sprite.flip_h = true

func set_head_rotation() -> void:
	var mouse_pos = owner.get_global_mouse_position()
	head_sprite.look_at(mouse_pos)
	if mouse_pos < head_sprite.get_global_position():
		head_sprite.flip_v = true
		head_sprite.offset.y = -head_offset
	else:
		head_sprite.flip_v = false
		head_sprite.offset.y = head_offset

func rotate_reticle() -> void:
	var mouse_pos = owner.get_global_mouse_position()
	
	reticle.look_at(mouse_pos)

func _process(delta: float) -> void:
	if owner:
		set_facing_direction()
		set_head_rotation()
		rotate_reticle()
