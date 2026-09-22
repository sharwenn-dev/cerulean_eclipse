class_name State
extends Node

var player: Player
var stats: PlayerStats
var animations: AnimatedSprite2D
var move_component
@export var reverse_while_backwards: bool = false
@export var follow_head: bool = false
@export var movement_locked: bool = false


func enter() -> void:
	pass

func exit() -> void:
	pass

func process_physics(delta: float) -> State:
	return null

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func get_movement_input() -> float:
	return move_component.get_movement_direction()

func get_jump() -> bool:
	return move_component.wants_jump()

func wants_ground_dash() -> float:
	return move_component.wants_ground_dash()

func clear_dash_state() -> void:
	move_component.clear_ground_dash()
