extends Node2D

@export var player_path: NodePath  # Path to the Player node
@onready var player: Node2D = get_node(player_path)

@export var audio_clip: AudioStream
@onready var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

@export var tilemap: TileMap
@export var tile_sound_manager: Node
@export var clock: Node

# Movement distance in pixels per beat
@export var move_distance: float = 16.0

# 80 BPM to seconds per beat
const BEAT_INTERVAL: float = 60.0 / 80.0
var beat_timer: float = 0.0
var move_dir = Vector2.ZERO
var should_follow_player = false

# Sound assets
var skill_activation_sound := preload("res://Audio/SFX/SFX_WhiteCaneDetect_.wav")
var knife_kill_sound := preload("res://Audio/SFX/SFX_Kill.wav")

# Scan state variables
var scanQueue: Array = []
var scanning := false
var kill_cand: Node = null
var current_ind := 0
var queued_beat_start := false

# Directions map
var direction_map := {
	Vector2.UP: [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1),
			Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)],
	Vector2.RIGHT: [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1),
			Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)],
	Vector2.DOWN: [Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1),
			Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)],
	Vector2.LEFT: [Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
			Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1)]
}

func _ready():
	z_index = 1
	add_child(audio_player)
	audio_player.stream = audio_clip
	if audio_clip and audio_clip.resource_path: # Set bus based on the initial audio_clip
		var file_name = audio_clip.resource_path.get_file()
		if file_name.begins_with("UI_"): audio_player.bus = "UI"
		elif file_name.begins_with("SFX_"): audio_player.bus = "SFX"
		elif file_name.begins_with("MS_"): audio_player.bus = "MusicBus"
		elif file_name.begins_with("VO_"): audio_player.bus = "Narration"
		# else: default bus (Master)

	await get_tree().process_frame

	if clock:
		clock.beat_tick.connect(_on_beat_tick)

func _process(delta: float) -> void:
	beat_timer += delta

	if beat_timer >= BEAT_INTERVAL:
		beat_timer = 0.0

		if should_follow_player and move_dir != Vector2.ZERO:
			global_position += move_dir * move_distance

func _input(event: InputEvent) -> void:
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

			# Play skill activation sound
			audio_player.stream = skill_activation_sound
			# skill_activation_sound is SFX_WhiteCaneDetect_.wav, so set bus to SFX
			audio_player.bus = "SFX"
			audio_player.play()

func _teleport_to_player() -> void:
	if player:
		global_position = player.global_position
		should_follow_player = true
		visible = true

func _destroy_enemies_in_area() -> void:
	var tile_size = 16
	var center_pos = global_position
	var half_area = tile_size * 1.5

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Node2D:
			var enemy_pos = enemy.global_position
			if abs(enemy_pos.x - center_pos.x) <= half_area and abs(enemy_pos.y - center_pos.y) <= half_area:
				enemy.queue_free()

func _on_beat_tick() -> void:
	if not scanning:
		return

	if queued_beat_start:
		queued_beat_start = false
		return

	if scanning and current_ind < scanQueue.size():
		var tile = scanQueue[current_ind]
		var world_pos = tilemap.map_to_local(tile)
		kill_cand = null

		tile_sound_manager.play_tile_sound_at(world_pos)
		current_ind += 1
	else:
		scanning = false
		kill_cand = null
