extends Control
var settings = MatchSettings.new()
signal start_match(settings: MatchSettings)
var last_focused: Button
var last_main_focus: Button
var using_controller: bool
var original_positions: Dictionary = {}
var submenu_tween: Tween
var submenu_generation := 0
var submenu_open := false
var skip_submenu_animation := false
var returning_from_cancel := false
var submenu_button_tweens: Array[Tween] = []
var buttons: Array[Button] = []
var first_button: Button
var current_open_submenu: Button
const BUTTON_SPACING := 40.0
const START_X := -20.0
const START_Y := 190.0
enum InputMode {
	MOUSE,
	CONTROLLER
}

var input_mode := InputMode.MOUSE
@onready var submenubackground = $SubMenuBackground
@onready var submenuwhiteline = $SubMenuBackground/Whiteline

var training_options := [
	"Free Training",
	"Sandbox",
	"Tutorial"
	
]
var versus_options := [
	"VS Player",
	"Watch Replay",
	
	
]
var online_options := [
	"Quick Play",
	"Find Server",
	"Host",
	
	
]
func _save_settings(gamemode) -> void:
	if gamemode == "Sandbox":
		settings.rounds_enabled = false
		settings.match_length = INF
		settings.map = 1
	pass
	
func _open_submenu(submenu, animate_buttons := true) -> void:
	print("open")
	submenu_open = true
	submenu_generation += 1
	var generation := submenu_generation
	if submenu_tween:
		submenu_tween.kill()
	var material := submenubackground.material as ShaderMaterial
	submenubackground.visible = true
	
	submenu_tween = create_tween()
	submenu_tween.set_parallel()
	submenu_tween.tween_method(
		func(value):
			material.set_shader_parameter("alpha", value),
		material.get_shader_parameter("alpha"),
		1.0,
		0.2
	)
	submenu_tween.tween_property(
		submenuwhiteline,
		"size",
		Vector2(5.0, 699.0),
		0.15
	)
	submenu_tween.tween_property(
		submenubackground,
		"size",
		Vector2(756.0, 695.0),
		0.2
	)
	_init_submenu_buttons(generation,submenu,animate_buttons)
func _close_submenu() -> void:
	if not submenu_open:
		return

	print("close")

	submenu_open = false
	submenu_generation += 1

	if submenu_tween:
		submenu_tween.kill()
	buttons.clear()
	first_button = null

	var container := $SubMenuBackground
	var preset := container.get_node("MarginContainer")
	var material := submenubackground.material as ShaderMaterial

	for child in container.get_children():
		if child != preset and child != submenuwhiteline:
			child.queue_free()
	submenu_tween = create_tween()
	submenu_tween.set_parallel()

	submenu_tween.tween_method(
		func(value):
			material.set_shader_parameter("alpha", value),
		material.get_shader_parameter("alpha"),
		0.0,
		0.05
	)

	submenu_tween.tween_property(
		submenuwhiteline,
		"size",
		Vector2(5.0, 0.0),
		0.05
	)

	submenu_tween.finished.connect(func():
		if not submenu_open:
			submenubackground.size = Vector2(0.0, 695.0)

			if material.get_shader_parameter("alpha") == 0.0:
				submenubackground.visible = false
	)
		
func _on_button_focused_entered(button: Button) -> void:
	print("Focused:", button.name)
	var tween = create_tween()
	tween.tween_property(
		button,
		"position",
		original_positions[button] + Vector2(20.0, 0.0),
		0.1
	)
	#choose what button opens what submenu
	if button.name == "TrainingMode":
		_open_submenu(training_options, not returning_from_cancel)
	elif button.name == "LocalMatch":
		_open_submenu(versus_options, not returning_from_cancel)
	elif button.name == "Multiplayer":
		_open_submenu(online_options, not returning_from_cancel)
	else:
		_close_submenu()
	returning_from_cancel = false
func _on_button_focused_exited(button: Button) -> void:
	var tween := create_tween()

	tween.tween_property(
		button,
		"position",
		original_positions[button],
		0.2
	)
	if button.name == "TrainingMode":
		#_close_submenu()
		pass
	
func _on_button_selected(button: Button) -> void:
	#Choose what buttons have submenus
	if (button.name == "TrainingMode" or button.name == "LocalMatch" or button.name == "Multiplayer") and first_button:
		first_button.grab_focus.call_deferred()
	if button.name == "Sandbox":
		_save_settings("Sandbox")
		start_match.emit(settings)
		queue_free()
func _init_submenu_buttons(generation: int, submenu, animatebuttons: bool) -> void:
	var container := $SubMenuBackground
	var preset := container.get_node("MarginContainer")
	
	buttons.clear()
	first_button = null
	for child in container.get_children():
		if child != preset and child != submenuwhiteline:
			child.queue_free()

	await get_tree().process_frame

	if generation != submenu_generation:
		return

	for i in submenu.size():
		if generation != submenu_generation:
			return
		var item := preset.duplicate()
		var button := item.get_node("ButtonPreset")
		if first_button == null:
			first_button = button 

		button.text = submenu[i]
		button.name = button.text.replace(" ","")
		button.pressed.connect(func():
				_on_button_selected(button)
		)
		item.visible = true
		button.focus_mode = Control.FOCUS_ALL
		container.add_child(item)
		buttons.append(button)

		item.position = Vector2(
			START_X,
			START_Y + i * BUTTON_SPACING
		)

		if animatebuttons:
			var tween := create_tween()

			tween.tween_interval(i * 0.05)

			tween.tween_property(
				item,
				"position:x",
				20.0,
				0.4
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			item.position.x = 20.0
			if generation != submenu_generation:
				return

	for i in buttons.size():
		if i > 0:
			buttons[i].focus_neighbor_top = buttons[i - 1].get_path()

		if i < buttons.size() - 1:
			buttons[i].focus_neighbor_bottom = buttons[i + 1].get_path()
func _on_focus_changed(control: Control) -> void:
	last_focused = control
	if control.get_parent() == self:
		last_main_focus = control
	
func focus_controller():
	if last_focused == null:
			$Multiplayer.grab_focus.call_deferred()
	else:
		last_focused.grab_focus.call_deferred()
		using_controller = true
		
		
func _ready():

	for child in get_children():
		if child is Button:
			original_positions[child] = child.position
			child.focus_entered.connect(func():
				_on_button_focused_entered(child)
			)
			child.focus_exited.connect(func():
				_on_button_focused_exited(child)
			)
			child.mouse_entered.connect(func():
				_on_button_focused_entered(child)
			)
			child.mouse_exited.connect(func():
				_on_button_focused_exited(child)
			)
			child.pressed.connect(func():
				_on_button_selected(child)
			)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and using_controller:
		get_viewport().gui_release_focus()
		using_controller = false
	elif event is InputEventJoypadMotion and not using_controller and abs(event.axis_value) > 0.2:
		focus_controller()
	elif  event is InputEventJoypadButton and not using_controller:
		focus_controller()
	elif event.is_action_pressed("ui_cancel"):
		if submenu_open:
			returning_from_cancel = true
			_close_submenu()
			last_main_focus.grab_focus.call_deferred()

func _on_close_game_pressed() -> void:
	get_tree().quit()

func _on_local_match_pressed() -> void:
	

	visible = false
	start_match.emit(settings)
	#pass # Replace with function body.
