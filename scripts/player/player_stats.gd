class_name PlayerStats
extends Resource

@export var base_move_speed: float = 200.0
@export var run_move_speed: float = 400.0
@export var gravity: float = 800.0
@export var jump_force: float = -500.0
@export var dash_force: float = 1000.0
@export var friction: float = 100.0
@export var health: float = 100.0

# amount in the air
@export var max_jumps: int = 1
@export var jumps: int = 1
@export var max_dashes: int = 1
@export var dashes: int = 1

@export var grounded = true

# only includes things that can currently change
func save_stats() -> Dictionary:
	return {
		"health": health,
		"jumps": jumps,
		"dashes": dashes,
		"grounded": grounded
	}

func load_stats(data: Dictionary) -> void:
	health = data["health"]
	jumps = data["jumps"]
	dashes = data["dashes"]
	grounded = data["grounded"]
