extends Node2D

@export var tilemap: TileMap
@export var siren_tile: Vector2i
@export var direction: Vector2i = Vector2i.DOWN
@export var path_length: int = 6
@export var road_tile_id: int = 6
@export var sound_id: String = "siren"

var is_alive := true

func _ready():
	# rotate the graph to match the targeteed direction
	rotate_sprite_to_face_direction()

func rotate_sprite_to_face_direction():
	if not has_node("Sprite2D"):
		return
	
	match direction:
		Vector2i(1, 0):  $Sprite2D.rotation_degrees = 0     # down
		Vector2i(0, 1):  $Sprite2D.rotation_degrees = 90    # left
		Vector2i(-1, 0): $Sprite2D.rotation_degrees = 180   # up
		Vector2i(0, -1): $Sprite2D.rotation_degrees = -90   # right
		_: print("Unknown siren direction:", direction)

func is_siren_tile(tile: Vector2i) -> bool:
	return tile == siren_tile

# controls the distance from siren tile
func get_attack_level(tile: Vector2i) -> int:
	if not is_alive:
		return -1
	for i in range(1, path_length + 1):
		if tile == siren_tile + direction * i:
			return path_length - i + 1
	return -1

# if player press space when detect siren
func die():
	if not is_alive:
		return

	is_alive = false
	print("Siren defeated at", siren_tile)

	tilemap.set_cell(0, siren_tile, road_tile_id)

	for i in range(1, path_length + 1):
		var tile = siren_tile + direction * i
		tilemap.set_cell(0, tile, road_tile_id)

	queue_free()
