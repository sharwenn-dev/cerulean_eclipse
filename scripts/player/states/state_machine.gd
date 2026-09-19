class_name StateMachine
extends Node

@export var initial_state: State
@export var current_state: State

var states: Dictionary = {}

func init(player: CharacterBody2D, stats: PlayerStats) -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.player = player
			child.stats = stats
			child.transitioned.connect(_on_child_transitioned)
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _on_child_transitioned(new_state_name: String) -> void:
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
