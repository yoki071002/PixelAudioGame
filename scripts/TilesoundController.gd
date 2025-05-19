extends Node

# exposed TileMap and AudioStreamPlayer to connect in the editor
@export var tilemap: TileMap
@export var audio_player: AudioStreamPlayer2D

# create dictionary to match sound path by tile id
var tile_sounds := {
	# id=3: end
	3: preload("res://Audio/SFX/SFX_Win.wav"),
	# id=6: path
	6: preload("res://Audio/SFX/SFX_Detect_Road.wav"),
	# id=9: void
	9: preload("res://Audio/SFX/SFX_Detect_Die.wav")
}

func play_tile_sound_at(position: Vector2):
	var coords = tilemap.local_to_map(position)
	var tile_id = tilemap.get_cell_source_id(0, coords)

	if tile_sounds.has(tile_id):
		audio_player.stream = tile_sounds[tile_id]
		audio_player.play()
