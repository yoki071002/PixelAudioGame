extends Button

@export var level_scene: PackedScene
@export var activation_key: Key = Key.KEY_1  # Default key is '1'

func _ready():
	# Ensure the button is connected to the pressed signal
	self.pressed.connect(_on_button_pressed)

	# Ensure the node is processing input
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == activation_key:
			load_level()

func _on_button_pressed():
	load_level()

func load_level():
	if level_scene:
		get_tree().change_scene_to_packed(level_scene)
	else:
		push_error("No scene assigned to level_scene!")
