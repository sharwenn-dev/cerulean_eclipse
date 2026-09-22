extends Node


var playback:AudioStreamPlaybackPolyphonic


func _enter_tree() -> void:

	var player = AudioStreamPlayer.new()
	add_child(player)

	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)
	for child in $"..".get_children():
		if child is Button:
			child.focus_entered.connect(_play_hover)
			child.mouse_entered.connect(_play_hover)
			child.pressed.connect(_play_pressed)


func _on_node_added(node:Node) -> void:
	if node is Button:
		node.mouse_entered.connect(_play_hover)
		node.focus_entered.connect(_play_hover)
		node.pressed.connect(_play_pressed)


func _play_hover() -> void:
	playback.play_stream(preload("res://assets/ui/soundeffects/Modern1.wav"), 0, 0, randf_range(0.9, 1.1))


func _play_pressed() -> void:
	playback.play_stream(preload("res://assets/ui/soundeffects/Coffee2.wav"), 0, 0, randf_range(0.9, 1.1))
