extends CharacterBody2D

# tile size: 16x16 pixel
@export var tile_size := 16
@export var tilemap_node_path := NodePath("../TileMap")

var tilemap: TileMap

func _ready():
	tilemap = get_node(tilemap_node_path)

var can_move := true

func _physics_process(delta):
	# return if no movement allowed
	if not can_move:
		return

	# store the direction of movement
	var input_dir := Vector2.ZERO

	if Input.is_action_just_pressed("move_right"):
		input_dir.x += 1
	elif Input.is_action_just_pressed("move_left"):
		input_dir.x -= 1
	elif Input.is_action_just_pressed("move_down"):
		input_dir.y += 1
	elif Input.is_action_just_pressed("move_up"):
		input_dir.y -= 1

	if input_dir != Vector2.ZERO:
		var current_tile: Vector2 = tilemap.local_to_map(global_position)
		var target_tile := current_tile + input_dir
		print("Player tile: ", current_tile)

		# boundary check
		if (target_tile.x >= 0 and target_tile.x < 8 and
		   target_tile.y < 0 and target_tile.y > -13):
			global_position = tilemap.map_to_local(target_tile)
			print("Moved to: ", global_position)
