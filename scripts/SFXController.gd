extends Node

# 创建音频播放器节点
@onready var audio_player_x = AudioStreamPlayer.new()  # X坐标音效播放器
@onready var audio_player_y = AudioStreamPlayer.new()  # Y坐标音效播放器
@onready var clock = $"../Clock"  # 使用相对路径，Clock节点在同一层级
@onready var player = $"../Player"  # 获取玩家节点
@onready var tilemap = $"../TileMap"  # 获取TileMap节点

# 追踪状态
var last_tile_pos = Vector2i(-1, -1)  # 初始值设为无效坐标
var pending_location_announce = false  # 是否有待播放的位置音效
var x_sfx_path = ""  # X坐标音效路径
var y_sfx_path = ""  # Y坐标音效路径

func _ready():
	print("[SFXController] 初始化开始")
	
	# 添加音频播放器
	add_child(audio_player_x)
	add_child(audio_player_y)
	print("[SFXController] 音频播放器已添加")
	
	# 连接节拍信号
	if clock:
		clock.beat_tick.connect(_on_beat_tick)
		print("[SFXController] 成功连接到Clock节点")
	else:
		push_error("[SFXController] 找不到Clock节点")
	
	# 检查其他必要节点
	if not player:
		push_error("[SFXController] 找不到Player节点")
	if not tilemap:
		push_error("[SFXController] 找不到TileMap节点")

# _process仅用于检测玩家位置变化
func _process(_delta):
	if player and tilemap:
		var current_tile_pos = tilemap.local_to_map(player.global_position)
		
		# 只在瓦片位置变化时触发音效
		if current_tile_pos != last_tile_pos:
			prepare_location_sfx(current_tile_pos)
			last_tile_pos = current_tile_pos

# 准备位置音效
func prepare_location_sfx(tile_pos: Vector2i):
	# 计算音效编号（从1开始）
	var x_index = tile_pos.x + 1 # 0~7 -> 1~8
	var y_index = abs(tile_pos.y) # -1~-12 -> 1~12
	
	# 确保编号在有效范围内
	x_index = clamp(x_index, 1, 8)
	y_index = clamp(y_index, 1, 12)
	
	# 格式化编号为两位数字的字符串
	var x_num = str(x_index).pad_zeros(2)
	var y_num = str(y_index).pad_zeros(2)
	
	# 存储音效文件路径 - fixed capitalization here
	x_sfx_path = "res://Audio/SFX/SFX_DetectLocation_X_%s.wav" % x_num
	y_sfx_path = "res://Audio/SFX/SFX_DetectLocation_Y_%s.wav" % y_num
	
	print("[SFXController] 准备播放位置音效：X-%s, Y-%s" % [x_num, y_num])
	
	# 标记有待播放的位置音效
	pending_location_announce = true

# 当节拍发生时播放音效
func _on_beat_tick():
	if pending_location_announce and not audio_player_x.playing and not audio_player_y.playing:
		play_location_sfx()

# 同时播放X和Y位置音效
func play_location_sfx():
	if pending_location_announce:
		print("[SFXController] 播放位置音效")
		
		# 加载并播放X坐标音效
		var x_stream = load(x_sfx_path) if ResourceLoader.exists(x_sfx_path) else null
		if x_stream:
			audio_player_x.stream = x_stream
			audio_player_x.play()
		else:
			print("[SFXController] 无法加载X坐标音效: ", x_sfx_path)
		
		# 加载并播放Y坐标音效
		var y_stream = load(y_sfx_path) if ResourceLoader.exists(y_sfx_path) else null
		if y_stream:
			audio_player_y.stream = y_stream
			audio_player_y.play()
		else:
			print("[SFXController] 无法加载Y坐标音效: ", y_sfx_path)
		
		# 重置标记
		pending_location_announce = false


func _on_clock_beat_tick() -> void:
	pass # Replace with function body.
