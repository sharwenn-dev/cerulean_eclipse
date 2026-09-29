extends Node
@onready var match_setup = $"../MainMenu"
var match_settings: MatchSettings
var current_map = ""
var player_scene = preload("res://scenes/player.tscn")


func _ready() -> void:
	match_setup.start_match.connect(_on_match_start)


func _on_defeat(player, timeofdeath) -> void:
	if not match_settings.rounds_enabled:
		return
	print(player + " loses!")
	print("died at frame " + str(MatchManager.current_frame))
	MatchManager.match_active = false
	
func _display_error(error: String):
	var label = Label.new()
	label.add_theme_color_override("font_color", Color(1,0,0,1))
	label.text = error
	printerr(error)
	add_child(label)
	
func _on_match_start(settings: MatchSettings):
	match_settings = settings
	
	var path = "res://maps/map" + str(match_settings.map) + ".tscn"
	var map_scene = load(path)
	var error = FileAccess.get_open_error()

	if not ResourceLoader.exists(path):
		var err = str("Path: ", path, " File not found.")
		_display_error(err)
		return
	elif error != OK:
		var err = "An error has occured. Error code: " + str(error)
		_display_error(err)
		return
	else:
		var map = map_scene.instantiate()
		var player = player_scene.instantiate()
		$"..".add_child(player)
		$"../Stage".add_child(map)
		MatchManager.match_active = true
		player.defeat.connect(_on_defeat)
