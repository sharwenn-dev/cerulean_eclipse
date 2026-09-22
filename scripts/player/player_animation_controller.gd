class_name PlayerAnimationController
extends Node

@onready var mouse_pos = owner.get_global_mouse_position()

@export var animation_player: AnimationPlayer
@onready var body_sprite = owner.find_child("Body")
@onready var head_sprite = owner.find_child("Head")
@onready var reticle = owner.find_child("AimHandler")

@onready var state_machine = owner.find_child("StateMachine")

@export var head_offset = 30
@export var base_anim_speed = 1.0
@export var current_anim_speed = base_anim_speed

func play_animation(anim_name: String) -> void:
	if animation_player:
		animation_player.play(anim_name)

func set_animation_speed(anim_speed: float) -> void:
	animation_player.speed_scale = anim_speed

func set_animation_direction() -> void:
	if not state_machine.current_state.reverse_while_backwards:
		set_animation_speed(abs(current_anim_speed))
		return
	if owner.is_moving_backwards():
		set_animation_speed(-abs(current_anim_speed))
	else:
		set_animation_speed(abs(current_anim_speed))

func set_facing_direction() -> void:
	if not owner.has_node("Body"):
		return
	if state_machine.current_state.movement_locked:
		return
	mouse_pos = owner.get_global_mouse_position()
	if mouse_pos.x > owner.global_position.x:
		body_sprite.flip_h = false
	elif mouse_pos.x < owner.global_position.x:
		body_sprite.flip_h = true

# will refactor later for efficiency 
func set_head_rotation() -> void:
	head_sprite.rotation = reticle.rotation
	if mouse_pos < head_sprite.get_global_position():
		head_sprite.flip_v = true
		head_sprite.offset.y = -head_offset
	else:
		head_sprite.flip_v = false
		head_sprite.offset.y = head_offset

func rotate_reticle() -> void:
	reticle.look_at(mouse_pos)

func _process(_delta: float) -> void:
	if owner:
		mouse_pos = owner.get_global_mouse_position()
		set_facing_direction()
		set_animation_direction()
		set_head_rotation()
		rotate_reticle()
