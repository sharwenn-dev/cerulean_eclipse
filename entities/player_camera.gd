extends Camera2D
  
@onready var myPlayer = $".."
@export var lerp_speed: float = 6.0

func _process(delta: float) -> void:
	offset = offset.lerp(myPlayer.velocity * 0.17, delta * lerp_speed)
