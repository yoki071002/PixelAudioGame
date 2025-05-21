extends CharacterBody2D

# tile size: 16x16 pixel
@export var tile_size := 16
@export var tilemap_node_path := NodePath("../TileMap")
@onready var blind_cane = $BlindCane
@onready var audio_player = $AudioPlayer

var tilemap: TileMap
var can_move := true
var ready_to_play := false

func _ready():
	# 延迟引用设置，以确保场景树完全准备好
	call_deferred("_setup_player_references")
	
	# 加载LevelCompleteManager中的Coin数据（这个可以立即执行，因为它不依赖于场景节点）
	var lcm_script_resource = load("res://scripts/LevelCompleteManager.gd")
	lcm_script_resource.load_coins()

func _setup_player_references():
	# 确保 blind_cane 实例有效
	if not is_instance_valid(blind_cane):
		printerr("[Player] _setup_player_references: BlindCane node is invalid!")
		return

	tilemap = get_node(tilemap_node_path)
	if not is_instance_valid(tilemap):
		printerr("[Player] _setup_player_references: Main tilemap node is invalid! Path: ", tilemap_node_path)
		# 根据游戏逻辑，这里可能需要 return 或者设置 can_move = false

	# 为 BlindCane 设置引用
	var cane_tilemap = get_node_or_null("../TileMap") # 使用 get_node_or_null 避免硬错误
	if is_instance_valid(cane_tilemap):
		blind_cane.tilemap = cane_tilemap
	else:
		printerr("[Player] _setup_player_references: TileMap for BlindCane not found or invalid at path '../TileMap'")

	var cane_clock = get_node_or_null("../Clock")
	if is_instance_valid(cane_clock):
		blind_cane.clock = cane_clock
	else:
		printerr("[Player] _setup_player_references: Clock for BlindCane not found or invalid at path '../Clock'")

	var cane_sound_manager = get_node_or_null("../TilesoundController")
	if is_instance_valid(cane_sound_manager):
		blind_cane.tile_sound_manager = cane_sound_manager
	else:
		printerr("[Player] _setup_player_references: TilesoundController for BlindCane not found or invalid at path '../TilesoundController'")

	blind_cane.player = self 
	print("Resolved tilemap in Player.gd: ", get_node("../TileMap"))

	print("[Player] Passed references to BlindCane")
	
	ready_to_play = true

func _physics_process(delta):
	# return if no movement allowed
	# 或者如果 tilemap 未成功初始化
	if not can_move or not is_instance_valid(tilemap):
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
		# print("Player tile: ", current_tile) # 可以取消注释以进行调试

		if (target_tile.x >= 0 and target_tile.x < 8 and
			target_tile.y < 0 and target_tile.y > -13):

			# move the player
			global_position = tilemap.map_to_local(target_tile)
			# print("Moved to: ", global_position) # 可以取消注释以进行调试

			# Check the tile the player just moved to
			var tile_data = tilemap.get_cell_tile_data(0, target_tile) # 获取瓦片数据
			var tile_source_id = -1
			if tile_data: # 确保 tile_data 不是 null
				# 在Godot 4.x中，通常通过atlas coordinates和source id来识别瓦片以下假设想检查的是 source_id，如果您的瓦片集设置不同，可能需要调整
				tile_source_id = tilemap.get_cell_source_id(0, target_tile)
			# print("踩到了tile Source ID: ", tile_source_id) # 可以取消注释以进行调试
			
			# 检查是否踩到了死亡瓦片 (ID 9)
			if tile_source_id == 9:
				die()
			# 检查是否踩到了胜利瓦片 (ID 3)
			elif tile_source_id == 3:
				win()

# 玩家死亡
func die():
	if not can_move: return # 防止重复调用
	print("[Player] Stepped on lava. Died.")
	can_move = false

	audio_player.stream = load("res://Audio/SFX/SFX_Die.wav")
	audio_player.play()

	await audio_player.finished
	get_tree().change_scene_to_file("res://levels/ESCMenu.tscn")

# 玩家胜利
func win():
	if not can_move: return # 防止重复调用
	print("[Player] Stepped on victory tile. Won!")
	can_move = false
	
	audio_player.stream = load("res://Audio/SFX/SFX_Win.wav")
	audio_player.play()
	
	var level_complete_manager = find_level_complete_manager()
	if is_instance_valid(level_complete_manager):
		await audio_player.finished
		level_complete_manager.complete_level()
	else:
		printerr("[Player] win: LevelCompleteManager is invalid or not found!")
		await audio_player.finished
		get_tree().change_scene_to_file("res://levels/level_select.tscn")

# 查找场景中的LevelCompleteManager
func find_level_complete_manager():
	var lcm_script_resource = load("res://scripts/LevelCompleteManager.gd")
	var parent_node = get_parent()
	# 如果都找不到，并且你的设计允许动态创建，则创建一个新的
	print("[Player] LevelCompleteManager not found, creating a new one.")
	var new_lcm_instance = Node.new() # 创建一个基础 Node
	new_lcm_instance.set_script(lcm_script_resource) # 应用脚本
	new_lcm_instance.name = "LevelCompleteManager" # 给它一个名字以便查找（如果需要）
	# 将其添加到关卡的根节点（即玩家的父节点）
	if is_instance_valid(parent_node):
		parent_node.add_child(new_lcm_instance)
		return new_lcm_instance
	else:
		printerr("[Player] Cannot create LevelCompleteManager as player has no parent.")
		return null

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
	if not ready_to_play:
		return
		
	if event.is_action_pressed("blind_up"):
		blind_cane.scan_tiles(Vector2.UP)
	elif event.is_action_pressed("blind_down"):
		blind_cane.scan_tiles(Vector2.DOWN)
	elif event.is_action_pressed("blind_left"):
		blind_cane.scan_tiles(Vector2.LEFT)
	elif event.is_action_pressed("blind_right"):
		blind_cane.scan_tiles(Vector2.RIGHT)
