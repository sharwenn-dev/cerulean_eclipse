extends Control
@onready var tree = $Tree
var settings = MatchSettings.new()
var roundsitem: TreeItem
var matchlengthitem: TreeItem
var mapitem: TreeItem
signal start_match(settings: MatchSettings)


func _ready():
	tree.columns = 2

	var root = tree.create_item()
	root.set_text(0, "Match Settings")

	roundsitem = tree.create_item(root)
	roundsitem.set_text(0, "Enable Rounds")
	roundsitem.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	roundsitem.set_checked(1, true)
	roundsitem.set_editable(1, true)

	matchlengthitem = tree.create_item(root)
	matchlengthitem.set_text(0, "Match Length")
	matchlengthitem.set_editable(1, true)
	matchlengthitem.set_text(1, "350")

	mapitem = tree.create_item(root)
	mapitem.set_text(0, "Map 1-3")
	mapitem.set_editable(1, true)
	mapitem.set_text(1, "1")


func _on_start_match_pressed() -> void:
	settings.rounds_enabled = roundsitem.is_checked(1)
	settings.match_length = int(matchlengthitem.get_text(1))
	settings.map = int(mapitem.get_text(1))

	visible = false
	start_match.emit(settings)


func _on_close_game_pressed() -> void:
	pass # Replace with function body.
