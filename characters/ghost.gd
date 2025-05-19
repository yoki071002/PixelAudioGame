extends Node2D

@export var tilemap: TileMap  # level scene
@export var ghost_tile: Vector2i  # ghost tile position
@export var sound_id: String = "ghost"  # sound identifier
@export var attack_sound_id: String = "ghost_attack"

var is_alive := true

# get the 4 attack regions around the ghost
func get_attack_tiles() -> Array:
	return [
		ghost_tile + Vector2i(0, -1),  # up
		ghost_tile + Vector2i(0, 1),   # down
		ghost_tile + Vector2i(-1, 0),  # left
		ghost_tile + Vector2i(1, 0)    # right
	]

func is_attack_tile(tile: Vector2i) -> bool:
	return get_attack_tiles().has(tile)

func is_ghost_tile(tile: Vector2i) -> bool:
	return tile == ghost_tile

# called when player press space while detecting ghost
func die():
	if not is_alive:
		return

	is_alive = false
	print("Ghost defeated at", ghost_tile)

	# replace ghost + attack tiles with road tile
	tilemap.set_cell(0, ghost_tile, 6)
	for tile in get_attack_tiles():
		tilemap.set_cell(0, tile, 6)

	queue_free()
