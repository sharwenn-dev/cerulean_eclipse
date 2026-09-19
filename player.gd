class_name Player
extends CharacterBody2D

@export var stats: PlayerStats
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_controller: PlayerAnimationController = $AnimationController

func _ready() -> void:
	if not stats:
		stats = PlayerStats.new()
		
	state_machine.init(self, stats)

func _process(delta: float) -> void:
	state_machine.update(delta)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * stats.base_move_speed

	move_and_slide()
