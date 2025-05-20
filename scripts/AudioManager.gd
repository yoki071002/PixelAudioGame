extends Node

const SFX_PLAYER_NAME = "SFXPlayerInstance"
const MUSIC_PLAYER_NAME = "MusicPlayerInstance"
const NARRATION_PLAYER_NAME = "NarrationPlayerInstance"

var sfx_player_node: AudioStreamPlayer
var music_player_node: AudioStreamPlayer
var narration_player_node: AudioStreamPlayer

func _ready():
	sfx_player_node = get_node_or_null(SFX_PLAYER_NAME)
	if not is_instance_valid(sfx_player_node):
		sfx_player_node = AudioStreamPlayer.new()
		sfx_player_node.name = SFX_PLAYER_NAME
		add_child(sfx_player_node)

	music_player_node = get_node_or_null(MUSIC_PLAYER_NAME)
	if not is_instance_valid(music_player_node):
		music_player_node = AudioStreamPlayer.new()
		music_player_node.name = MUSIC_PLAYER_NAME
		add_child(music_player_node)

	narration_player_node = get_node_or_null(NARRATION_PLAYER_NAME)
	if not is_instance_valid(narration_player_node):
		narration_player_node = AudioStreamPlayer.new()
		narration_player_node.name = NARRATION_PLAYER_NAME
		add_child(narration_player_node)
	
	print("AudioManager ready. Players ensured/created with names: ", SFX_PLAYER_NAME, ", ", MUSIC_PLAYER_NAME, ", ", NARRATION_PLAYER_NAME)
	print_player_status("_ready")

func print_player_status(context: String):
	print("AudioManager Status Context: ", context)
	if is_instance_valid(sfx_player_node): print("  SFXPlayer ('%s'): Valid, ID: %s" % [SFX_PLAYER_NAME, sfx_player_node.get_instance_id()])
	else: printerr("  SFXPlayer ('%s'): INVALID or Stale Reference" % SFX_PLAYER_NAME)

	if is_instance_valid(music_player_node): print("  MusicPlayer ('%s'): Valid, ID: %s" % [MUSIC_PLAYER_NAME, music_player_node.get_instance_id()])
	else: printerr("  MusicPlayer ('%s'): INVALID or Stale Reference" % MUSIC_PLAYER_NAME)

	if is_instance_valid(narration_player_node): print("  NarrationPlayer ('%s'): Valid, ID: %s" % [NARRATION_PLAYER_NAME, narration_player_node.get_instance_id()])
	else: printerr("  NarrationPlayer ('%s'): INVALID or Stale Reference" % NARRATION_PLAYER_NAME)

func play_audio(audio_stream: AudioStream, type: String = "sfx", volume_db: float = 0.0, pitch_scale: float = 1.0):
	if not audio_stream:
		printerr("AudioManager.play_audio: audio_stream is null. Cannot play.")
		return

	print_player_status("play_audio_start for type: " + type)
	
	type = type.strip_edges().trim_prefix("\"").trim_suffix("\"")

	var player_to_use: AudioStreamPlayer = null
	var player_name_to_check: String = ""

	if type == "sfx":
		player_to_use = sfx_player_node
		player_name_to_check = SFX_PLAYER_NAME
	elif type == "music":
		player_to_use = music_player_node
		player_name_to_check = MUSIC_PLAYER_NAME
	elif type == "narration":
		player_to_use = narration_player_node
		player_name_to_check = NARRATION_PLAYER_NAME
	else:
		printerr("AudioManager.play_audio: Unknown audio type '", type, "'")
		return

	if not is_instance_valid(player_to_use):
		printerr("AudioManager.play_audio: Variable for type '", type, "' (",player_name_to_check,") holds an INVALID instance reference before assignment.")
		var fresh_node_reference = get_node_or_null(player_name_to_check)
		if is_instance_valid(fresh_node_reference):
			printerr("AudioManager.play_audio: Successfully re-fetched '", player_name_to_check, "' from tree. Variable was stale. Updating variable.")
			player_to_use = fresh_node_reference
			if type == "sfx": sfx_player_node = player_to_use
			elif type == "music": music_player_node = player_to_use
			elif type == "narration": narration_player_node = player_to_use
		else:
			printerr("AudioManager.play_audio: CRITICAL - Node '", player_name_to_check, "' is also invalid or not found in tree. Cannot play audio.")
			printerr("AudioManager.play_audio: Attempting to recreate player '", player_name_to_check, "'")
			var new_player = AudioStreamPlayer.new()
			new_player.name = player_name_to_check
			add_child(new_player)
			player_to_use = new_player
			
			if type == "sfx": sfx_player_node = player_to_use
			elif type == "music": music_player_node = player_to_use
			elif type == "narration": narration_player_node = player_to_use
			
			if not is_instance_valid(player_to_use):
				printerr("AudioManager.play_audio: FAILED to recreate player '", player_name_to_check, "'.")
				return
			else:
				print("AudioManager.play_audio: Successfully recreated player '", player_name_to_check, "'.")

	if not is_instance_valid(player_to_use):
		printerr("AudioManager.play_audio: CRITICAL - Player for '", type, "' (",player_name_to_check,") is STILL INVALID right before '.stream' assignment. Aborting.")
		return

	player_to_use.stream = audio_stream
	player_to_use.volume_db = volume_db
	player_to_use.pitch_scale = pitch_scale
	player_to_use.play()

func stop_audio(type: String = "sfx"):
	var player_to_use: AudioStreamPlayer = null
	if type == "sfx": player_to_use = sfx_player_node
	elif type == "music": player_to_use = music_player_node
	elif type == "narration": player_to_use = narration_player_node
	
	if is_instance_valid(player_to_use):
		player_to_use.stop()
	else:
		printerr("AudioManager.stop_audio: Player for type '", type, "' is invalid.")
