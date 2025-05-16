extends Node2D;

# 32x32 pixel tiles
const TILE_SIZE = 32;

# when the scene is fully generated
# find the TileMap node inside targeted Level Node
@onready var tilemap: TileMap = get_parent().get_node("Level/TileMap2");

# if moving is enabled
var move_bool = true;

# main function: control the operation
func move_handle(event):
	# error handling: invalid input
	if not move_bool:
		return;
		
	var direction := Vector2.ZERO;
	
	if Input.is_action_just_pressed("move_up"):
		direction = Vector2.UP;
	elif Input.is_action_just_pressed("move_down"):
		direction = Vector2.DOWN;
	elif Input.is_action_just_pressed("move_left"):
		direction = Vector2.LEFT;
	elif Input.is_action_just_pressed("move_right"):
		direction = Vector2.RIGHT;
	
	# check if player actually type anything
	# if yes, move player by the direction
	if direction != Vector2.ZERO:
		move_player(direction);
	# if press space, shows the surrounding 9 tiles respectively
	elif Input.is_action_just_pressed("blind_cane"):
		blind_cane();

# helper function 1: move player
func move_player(direction: Vector2):
	global_position += direction*TILE_SIZE;
	move_bool = false;
	# set a slight delay before playing the sound
	await get_tree().create_timer(0.25).timeout;
	play_tile_sound(global_position);
	move_bool = true;

# helper function 2: play the specified sound
func play_tile_sound(posi: Vector2):
	# set global position as coordinates in TileMap
	var cell = tilemap.local_to_map(posi);
	# retrieve specified cell's tile object
	var tile_data = tilemap.get_cell_tile_data(0, cell);
	# check whether a valid sound for given tile exist
	if tile_data and tile_data.has_custom_data("sound"):
		var sound_name = tile_data.get_custom_data("sound");
		var sound_path = "res://sounds/%s" % sound_name;
		# error handling: check file existence before loading
		if ResourceLoader.exists(sound_path):
			var player = AudioStreamPlayer.new();
			add_child(player);
			player.stream = load(sound_path);
			player.play();
			await player.finished;
			player.queue_free();
		else:
			print("Sound not found:", sound_path);
	else:
		print("No sound data on this tile");

# helper function 3: blind cane
func blind_cane():
	# player's current standing tile
	var origin = tilemap.local_to_map(global_position);
	var surround = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
		Vector2(-1,  0), Vector2(0,  0), Vector2(1,  0),
		Vector2(-1,  1), Vector2(0,  1), Vector2(1,  1),
	]
	
	var delay = 0.0;
	for sur in surround:
		var cell = origin + sur;
		var tile_data = tilemap.get_cell_tile_data(0, cell);
		
		# if it's the current position
		var is_center = sur == Vector2(0, 0);
		
		if tile_data and tile_data.has_custom_data("sound"):
			var sound_name = tile_data.get_custom_data("sound");
			var sound_path = "res://sounds/%s" % sound_name;

			if ResourceLoader.exists(sound_path):
				if is_center:
					# play the tile sound
					await get_tree().create_timer(delay).timeout;
					# delayed call
					play_tile_sound(global_position);
				else:
					# play the special sound
					play_delayed_sound(sound_path, delay);
			else:
				print("Sound not found:", sound_path);
		else:
			print("No sound data at", cell);

		delay += 0.125

# helper function 4: play the special sound
# *** update after sound
func play_delayed_sound(path: String, delay: float):
	await get_tree().create_timer(delay).timeout;
	var player = AudioStreamPlayer.new();
	add_child(player);
	player.stream = load(path);
	player.play();
	await player.finished;
	player.queue_free();
		
