class_name PlayerAnimationController
extends Node

@onready var mouse_pos = owner.get_global_mouse_position()

@export var animation_player: AnimationPlayer
@onready var body_sprite = owner.find_child("Body")
@onready var head_sprite = owner.find_child("Head")
@onready var reticle = owner.find_child("AimHandler")

@export var head_offset = 30
@export var base_anim_speed = 1.0
@export var current_anim_speed = base_anim_speed

func play_animation(anim_name: String) -> void:
	if animation_player and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func set_animation_speed(anim_speed: float) -> void:
	animation_player.speed_scale = anim_speed

func set_animation_direction() -> void:
	if owner.is_moving_backwards(): # in the future this should only apply to certain states
		set_animation_speed(-current_anim_speed)
	else:
		set_animation_speed(current_anim_speed)

func set_facing_direction() -> void:
	if owner.has_node("Body"): # in the future we should be able to choose between the two versions below per state
	#	var direction := Input.get_axis("left", "right")  
	#	if direction != 0:
	#		body_sprite.flip_h = direction < 0
		mouse_pos = owner.get_global_mouse_position()
		if mouse_pos.x > owner.position.x:
			body_sprite.flip_h = false
		elif mouse_pos.x < owner.position.x:
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
		set_facing_direction()
		set_animation_direction()
		set_head_rotation()
		rotate_reticle()
