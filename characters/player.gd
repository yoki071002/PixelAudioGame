extends CharacterBody2D

# tile size: 16x16 pixel
@export var tile_size := 16
@export var tilemap_node_path := NodePath("../TileMap")
@onready var blind_cane = $BlindCane

var tilemap: TileMap
var can_move := true

func _ready():
	tilemap = get_node(tilemap_node_path)
	
	# Pass references from level scene into BlindCane
	blind_cane.tilemap = get_node("../TileMap")
	blind_cane.clock = get_node("../../Clock")
	blind_cane.tile_sound_manager = get_node("../../TilesoundController")
	blind_cane.player = self 

	print("[Player] Passed references to BlindCane")

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

			# move the player
			global_position = tilemap.map_to_local(target_tile)
			print("Moved to: ", global_position)

			# Check the tile the player just moved to
			var tile_id = tilemap.get_cell_source_id(0, target_tile)
			if tile_id == 9:
				die()

func die():
	print("[Player] Stepped on lava. Died.")
	can_move = false

	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://ESCMenu.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_collision_shape_2d_child_entered_tree(node: Node) -> void:
	pass # Replace with function body.


func _on_collision_shape_2d_child_exiting_tree(node: Node) -> void:
	pass # Replace with function body.

# controls blind cane skill
func _input(event):
	if event.is_action_pressed("blind_up"):
		blind_cane.scan_tiles(Vector2.UP)
	elif event.is_action_pressed("blind_down"):
		blind_cane.scan_tiles(Vector2.DOWN)
	elif event.is_action_pressed("blind_left"):
		blind_cane.scan_tiles(Vector2.LEFT)
	elif event.is_action_pressed("blind_right"):
		blind_cane.scan_tiles(Vector2.RIGHT)
