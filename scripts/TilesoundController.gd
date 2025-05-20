extends Node

# exposed TileMap and AudioStreamPlayer to connect in the editor
@export var tilemap: TileMap
@export var audio_player: AudioStreamPlayer2D

# create dictionary to match sound path by tile id
var tile_sounds := {
	# id=3: end
	3: preload("res://Audio/SFX/SFX_Detect_Win.wav"),
	# id=6: path
	6: preload("res://Audio/SFX/SFX_Detect_Road.wav"),
	# id=9: void
	9: preload("res://Audio/SFX/SFX_Detect_Die.wav")
}

# Main method used in BlindCane.gd for tile-based scanning
func play_tile_sound_at(tile_coords: Vector2i):
	var tile_id = tilemap.get_cell_source_id(0, tile_coords)

	if tile_sounds.has(tile_id):
		var stream = tile_sounds[tile_id]
		_play_one_shot(stream)

# More generic sound playback method (used for NPC detection)
func play(path: String):
	var stream = load(path)
	if stream:
		_play_one_shot(stream)
	else:
		push_error("TilesoundController: Failed to load sound: " + path)

# Core helper method for one-shot audio playback
func _play_one_shot(stream: AudioStream):
	var player = AudioStreamPlayer2D.new()
	player.stream = stream
	add_child(player)
	player.play()
	player.connect("finished", Callable(player, "queue_free"))
