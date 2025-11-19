extends Sprite2D

var radius := 25.0 # can be changed to any radius, equivalent to -y level for testing heights

func _ready() -> void:
	self.show()

# basic circle math i have to look up every time i do it
func _process(delta):
	var mouse_global = get_global_mouse_position()
	var player_global = get_parent().global_position
	var dir = (mouse_global - player_global).normalized()

	position = dir * radius
	rotation = dir.angle()
