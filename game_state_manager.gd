extends Node

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("players"):
		print(node.name)
		node.defeat.connect(_on_defeat)

func _on_defeat(player,timeofdeath) -> void:
	print(player+" loses!")
	print("died at "+str(timeofdeath)+" ms")
