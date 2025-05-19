extends Node2D

@export var player_path: NodePath  # Path to the Player node
@onready var player: Node2D = get_node(player_path)

func _process(delta: float) -> void:
	if player:
		if Input.is_action_just_pressed("ui_up") or \
		   Input.is_action_just_pressed("ui_down") or \
		   Input.is_action_just_pressed("ui_left") or \
		   Input.is_action_just_pressed("ui_right"):
			
			global_position = player.global_position
