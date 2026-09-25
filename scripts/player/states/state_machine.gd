class_name StateMachine
extends Node

@export var starting_state: State

var current_state: State


func init(player: Player, stats: PlayerStats, move_component: Node) -> void:
	for child in get_children():
		if child is State:
			child.player = player
			child.stats = stats
			child.move_component = move_component
	change_state(starting_state)


func change_state(new_state: State, is_loading: bool = false) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter(is_loading)
	
func process_physics(delta: float) -> void:
	# print("CURRENT STATE: ", current_state.name)
	var new_state := current_state.process_physics(delta)
	if new_state:
		change_state(new_state)
		
func process_input(event: InputEvent) -> void:
	var new_state := current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state := current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
