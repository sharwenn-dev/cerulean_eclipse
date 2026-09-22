class_name State
extends Node

signal transitioned(new_state_name: String)

var player: CharacterBody2D
var stats: PlayerStats

@export var reverse_while_backwards: bool = false
@export var follow_head: bool = false
@export var movement_locked: bool = false

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
