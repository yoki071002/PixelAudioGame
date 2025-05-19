extends Node2D

@export var player_path: NodePath  # Path to the Player node
@onready var player: Node2D = get_node(player_path)

@export var audio_clip: AudioStream
@onready var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

# Movement distance in pixels per beat
@export var move_distance: float = 16.0

# 80 BPM to seconds per beat
const BEAT_INTERVAL: float = 60.0 / 80.0
var beat_timer: float = 0.0
var move_dir = Vector2.ZERO
var should_follow_player = false

func _ready():
	z_index = 1  # make sure this object draws above enemies

	add_child(audio_player)
	audio_player.stream = audio_clip

func _process(delta: float) -> void:
	beat_timer += delta

	if beat_timer >= BEAT_INTERVAL:
		beat_timer = 0.0

		if should_follow_player and move_dir != Vector2.ZERO:
			global_position += move_dir * move_distance

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			move_dir = Vector2(0, -1)
			_teleport_to_player()
		elif event.keycode == KEY_DOWN:
			move_dir = Vector2(0, 1)
			_teleport_to_player()
		elif event.keycode == KEY_LEFT:
			move_dir = Vector2(-1, 0)
			_teleport_to_player()
		elif event.keycode == KEY_RIGHT:
			move_dir = Vector2(1, 0)
			_teleport_to_player()
		elif event.keycode == KEY_SPACE:
			# Stop all movement and make invisible
			should_follow_player = false
			move_dir = Vector2.ZERO
			visible = false

			# Destroy enemies in 3x3 area centered on this object's position
			_destroy_enemies_in_area()

			# Play sound
			if audio_player.stream:
				audio_player.play()

func _teleport_to_player():
	if player:
		global_position = player.global_position
		should_follow_player = true
		visible = true  # Make sure it’s visible when teleporting

func _destroy_enemies_in_area():
	# Size of each tile
	var tile_size = 16

	# Calculate the area bounds (3x3 tiles around global_position)
	var center_pos = global_position
	var half_area = tile_size * 1.5  # half width/height of 3 tiles

	# Iterate all nodes in "enemy" group
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Node2D:
			var enemy_pos = enemy.global_position
			if abs(enemy_pos.x - center_pos.x) <= half_area and abs(enemy_pos.y - center_pos.y) <= half_area:
				enemy.queue_free()
