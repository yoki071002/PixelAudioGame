extends Node

# External references
@export var tilemap: TileMap
@export var tile_sound_manager: Node
@export var player: Node
@export var clock: Node
@export var audio_player: AudioStreamPlayer2D  # used only for activation/kill sounds

# Sound assets
var skill_activation_sound := preload("res://Audio/SFX/SFX_WhiteCaneDetect_.wav")
var knife_kill_sound := preload("res://Audio/SFX/SFX_Kill.wav")

# Scan control
var scanQueue: Array = []
var scanning := false
var kill_cand: Node = null
var current_ind := 0
var queued_beat_start := false

# Scan speed control (in beats)
var beat_counter := 0
var scan_interval_beats := 30  # play 1 sound every 2 beats (i.e. every 0.75s if clock is 0.375s)

# Clockwise tile offsets based on input direction
var direction_map := {
	Vector2.UP:    [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)],
	Vector2.RIGHT: [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)],
	Vector2.DOWN:  [Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)],
	Vector2.LEFT:  [Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1)],
}

func _ready():
	await get_tree().process_frame
	if audio_player:
		audio_player.bus = "SFX"
	if clock:
		clock.beat_tick.connect(_on_beat_tick)
		print("BlindCane: Connected to clock.")
	else:
		push_error("BlindCane: Clock node not found.")

# Called by the player to start a scan in a direction
func scan_tiles(dir: Vector2):
	if scanning:
		return

	if tilemap == null or player == null:
		push_error("BlindCane: Missing tilemap or player.")
		return

	scanning = true
	current_ind = 0
	kill_cand = null
	queued_beat_start = true
	beat_counter = 0  # reset beat counter on new scan

	# Play initial activation sound
	audio_player.stream = skill_activation_sound
	audio_player.play()

	# Build scan queue
	var base_tile = tilemap.local_to_map(player.global_position)
	var offsets = direction_map.get(dir)
	scanQueue = offsets.map(func(offset): return base_tile + Vector2i(offset))

# Processes one scan every N beats
func _on_beat_tick():
	beat_counter += 1

	if beat_counter % scan_interval_beats != 0:
		return  # skip this beat

	print("BlindCane: beat_tick accepted")

	if not scanning:
		return

	if queued_beat_start:
		queued_beat_start = false
		return 

	if current_ind >= scanQueue.size():
		print("BlindCane: Scan complete.")
		scanning = false
		kill_cand = null
		return

	var tile = scanQueue[current_ind]
	var sound_played = false
	kill_cand = null

	print("Scanning tile index ", current_ind, ": ", tile)

	# Ghost detection
	for ghost in get_tree().get_nodes_in_group("ghost"):
		if ghost.is_alive:
			if ghost.is_attack_tile(tile):
				tile_sound_manager.play("res://Audio/SFX/SFX_Detect_GhostAttackRange.wav")
				sound_played = true
				break
			elif ghost.is_ghost_tile(tile):
				tile_sound_manager.play("res://Audio/SFX/SFX_Detect_Ghost.wav")
				kill_cand = ghost
				sound_played = true
				break

	# Siren detection
	if not sound_played:
		for siren in get_tree().get_nodes_in_group("siren"):
			if siren.is_alive:
				var level = siren.get_attack_level(tile)
				if level > 0:
					tile_sound_manager.play("res://Audio/SFX/SFX_Detect_Siren%d.wav" % level)
					sound_played = true
					break
				elif siren.is_siren_tile(tile):
					tile_sound_manager.play("res://Audio/SFX/SFX_Detect_Siren.wav")
					kill_cand = siren
					sound_played = true
					break

	# Default tile sound
	if not sound_played:
		tile_sound_manager.play_tile_sound_at(tile)

	current_ind += 1

# Allows player to attack detected ghost/siren
func _input(event):
	if event.is_action_pressed("attack") and kill_cand:
		kill_cand.die()
		kill_cand = null

		audio_player.stream = knife_kill_sound
		audio_player.play()
