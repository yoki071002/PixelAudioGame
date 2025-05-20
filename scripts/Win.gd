extends Area2D

@export var level_scene: PackedScene
@export var player_name: String = "Player"  # Set in Inspector

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.name == player_name:
		load_level()

func load_level():
	if level_scene:
		get_tree().call_deferred("change_scene_to_packed", level_scene)
	else:
		push_error("No scene assigned to level_scene!")
