extends Node

# initialize variables
# reference to tilemap, tilesoundController, player, clock
@export var tilemap: TileMap
@export var tile_sound_manager: Node
@export var player: Node
@export var clock: Node
@export var audio_player: AudioStreamPlayer2D

# activate skill + killer sound
var skill_activation_sound := preload("res://Audio/SFX/SFX_WhiteCaneDetect_.wav")
var knife_kill_sound := preload("res://Audio/SFX/SFX_Kill.wav")

# controls state tracking
var scanQueue: Array = [] #list of tiles to be tracked
var scanning := false #whether the skill currently in progress
var kill_cand: Node = null #whether current scanned tile is ghost/siren
var current_ind := 0 #which specific tile is being scanned now
var queued_beat_start := false

# directions for clockwise tile tracking
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

# controls the clock's rhythm beat signal
func _ready():
	await get_tree().process_frame
	if clock:
		clock.beat_tick.connect(_on_beat_tick)
	else:
		push_error("BlindCane: Clock node not found")
		
# callee function of the activated skill
func scan_tiles(dir: Vector2):
	# don't start new scan while one scan in progress
	if scanning:
		return
	
	scanning = true
	current_ind = 0
	kill_cand = null
	queued_beat_start = true
	
	# play the activation harp sound
	audio_player.stream = skill_activation_sound
	audio_player.play()
	
	# player's current tile
	var base_tile: Vector2i = tilemap.local_to_map(player.global_position)
	# the 8 tiles surround player's current tile
	var offsets = direction_map.get(dir)
	# convert offsets to actual positions
	scanQueue = offsets.map(func(offset): return base_tile + Vector2i(offset))
	
# handle the display of soiund and scanning
func _on_beat_tick():
	if not scanning:
		return

	if queued_beat_start:
		queued_beat_start = false
		return 
		
	if current_ind < scanQueue.size():
		var tile = scanQueue[current_ind]
		var world_pos = tilemap.map_to_local(tile)
		kill_cand = null

		var sound_played := false

		# ghosts
		for ghost in get_tree().get_nodes_in_group("ghost"):
			if ghost.is_alive:
				if ghost.is_attack_tile(tile):
					tile_sound_manager.play("res://audio/ghost_attack.wav")
					sound_played = true
					break
				elif ghost.is_ghost_tile(tile):
					tile_sound_manager.play("res://audio/ghost.wav")
					kill_cand = ghost
					sound_played = true
					break

		# sirens
		if not sound_played:
			for siren in get_tree().get_nodes_in_group("siren"):
				if siren.is_alive:
					var level = siren.get_attack_level(tile)
					if level > 0:
						tile_sound_manager.play("res://audio/siren_count%d.wav" % level)
						sound_played = true
						break
					elif siren.is_siren_tile(tile):
						tile_sound_manager.play("res://audio/siren.wav")
						kill_cand = siren
						sound_played = true
						break

		# normal property sound
		if not sound_played:
			tile_sound_manager.play_tile_sound_at(world_pos)

		current_ind += 1

	else:
		scanning = false
		kill_cand = null

func _input(event):
	if event.is_action_pressed("attack") and kill_cand:
		kill_cand.die()
		kill_cand = null
		
		# play knife sound
		audio_player.stream = knife_kill_sound
		audio_player.play()
