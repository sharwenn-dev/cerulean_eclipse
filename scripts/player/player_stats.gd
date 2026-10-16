class_name PlayerStats
extends Resource

# resources
@export var health: float = 100.0
@export var fp: int = 100

# amount in the air
@export var max_jumps: int = 2
@export var jumps: int = 2
@export var max_dashes: int = 2
@export var dashes: int = 2
@export var grounded = true
@export var flying = false
@export var current_start_frame: int # saves the starting frame of the action active this frame

@export var base_move_speed: float = 200.0
@export var run_move_speed: float = 445.0
@export var brake_limit: float = 450.0
@export var gravity: float = 800.0
@export var jump_force: float = -500.0
@export var dash_force: float = 700.0
@export var friction: float = 100.0

@export var flight_acceleration: float = 700.0
@export var air_friction: float = 200.0
@export var base_flight_speed: float = 600.0


# only includes things that can currently change
func save_stats() -> Dictionary:
	return {
		"health": health,
		"jumps": jumps,
		"dashes": dashes,
		"grounded": grounded,
		"start_frame": current_start_frame
	}

func load_stats(data: Dictionary) -> void:
	health = data["health"]
	jumps = data["jumps"]
	dashes = data["dashes"]
	grounded = data["grounded"]
	current_start_frame = data["start_frame"]
