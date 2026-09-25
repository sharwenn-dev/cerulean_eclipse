extends Node

var current_frame: int = 0
var match_active: bool = false

var history = {}
const MAX_HISTORY_FRAMES: int = 300 # last 5 seconds

func start_match() -> void:
	current_frame = 0
	history.clear()
	match_active = true

func _physics_process(delta: float) -> void:
	if not match_active:
		return
	
	current_frame += 1
	record_current_frame()

func record_current_frame() -> void:
	var frame_snapshot = {}
	
	for player in get_tree().get_nodes_in_group("players"):
		if player.has_method("save_state"):
			frame_snapshot[player.id] = player.save_state()
	
	history[current_frame] = frame_snapshot
	
	var oldest_frame = current_frame - MAX_HISTORY_FRAMES
	if history.has(oldest_frame):
		history.erase(oldest_frame)

func rollback_to(target_frame: int) -> void:
	if not history.has(target_frame):
		print("Rollback error: target frame ", target_frame, " not found in history. Frame: ", current_frame)
		return
	
	current_frame = target_frame
	var snapshot = history[target_frame]
	for player in get_tree().get_nodes_in_group("players"):
		if snapshot.has(player.id) and player.has_method("load_state"):
			player.load_state(snapshot[player.id])
