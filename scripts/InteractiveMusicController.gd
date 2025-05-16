extends Node

# 音乐层级配置
@export var layer_music_paths: Dictionary = {
	6: "res://audio/Music/Layer_7.ogg",
	7: "res://audio/Music/Layer_7.ogg",
	8: "res://audio/Music/Layer_8.ogg",
	9: "res://audio/Music/Layer_9.ogg"
}

# 音乐层级
var music_layers = {
	6: null, 
	7: null, # 7号键对应的音乐层
	8: null, # 8号键对应的音乐层
	9: null  # 9号键对应的音乐层
}

# 音频播放器
var layer_players = {}

# 时间追踪
@onready var clock = $"../Clock"  # 使用相对路径，Clock节点在同一层级
var beat_count = 0  # 音符计数
var measure_length = 8  # 一个小节包含个分音符
var queued_layer = null  # 队列中待播放的层级

# 当前状态
var active_layers = []  # 当前激活的层级

# 音乐总线名称
@export var music_bus_name: String = "MusicBus"

func _ready():
	print("[InteractiveMusicController] 初始化开始")

	
	# 连接节拍信号
	if clock:
		clock.beat_tick.connect(_on_beat_tick)
		print("[InteractiveMusicController] 成功连接到Clock节点")
	else:
		push_error("[InteractiveMusicController] 找不到Clock节点")
	
	# 为每个层级创建音频播放器
	for key in music_layers.keys():
		var player = AudioStreamPlayer.new()
		add_child(player)
		layer_players[key] = player
		print("[InteractiveMusicController] 为层级", key, "创建音频播放器")
		
		# 设置播放器的输出总线
		player.bus = music_bus_name
		
		# 预加载音乐
		if key in layer_music_paths:
			var music_path = layer_music_paths[key]
			if ResourceLoader.exists(music_path):
				music_layers[key] = load(music_path)
				print("[InteractiveMusicController] 预加载音乐:", music_path)
			else:
				push_error("[InteractiveMusicController] 音乐文件不存在:", music_path)

func _input(event):
	# 检查按键输入
	if event is InputEventKey and event.pressed:
		# 检查是否按下6,7,8,9键
		var layer_keys = {
			KEY_6: 6,
			KEY_7: 7,
			KEY_8: 8,
			KEY_9: 9
		}
		
		if event.keycode in layer_keys:
			var layer_id = layer_keys[event.keycode]
			toggle_layer(layer_id)

# 切换层级状态
func toggle_layer(layer_id):
	if layer_id in music_layers.keys():
		if layer_id in active_layers:
			# 如果层级已激活，则移除
			print("[InteractiveMusicController] 准备停止层级", layer_id)
			# 在下一个小节开始处停止
			queued_layer = -layer_id  # 负值表示要停止的层
		else:
			# 如果层级未激活，则添加
			print("[InteractiveMusicController] 准备播放层级", layer_id)
			# 检查音乐是否已加载
			if music_layers[layer_id] == null and layer_id in layer_music_paths:
				var music_path = layer_music_paths[layer_id]
				if ResourceLoader.exists(music_path):
					music_layers[layer_id] = load(music_path)
					print("[InteractiveMusicController] 加载音乐:", music_path)
				else:
					push_error("[InteractiveMusicController] 音乐文件不存在:", music_path)
					return
			elif music_layers[layer_id] == null:
				push_error("[InteractiveMusicController] 未配置层级", layer_id, "的音乐路径")
				return
			
			# 设置音频
			var player = layer_players[layer_id]
			player.stream = music_layers[layer_id]
			

			queued_layer = layer_id

# 当接收到节拍信号时
func _on_beat_tick():
	beat_count = (beat_count + 1) % measure_length
	
	# 在小节开始处处理层级变化
	if beat_count == 0 and queued_layer != null:
		if queued_layer > 0:
			# 启动新层级
			start_layer(queued_layer)
		elif queued_layer < 0:
			# 停止层级
			stop_layer(-queued_layer)
		
		queued_layer = null

# 启动特定层级
func start_layer(layer_id):
	if layer_id in music_layers.keys() and music_layers[layer_id] != null:
		var player = layer_players[layer_id]
		
		# 如果已经有其他层级在播放，同步播放位置
		if active_layers.size() > 0:
			var reference_player = layer_players[active_layers[0]]
			player.play(reference_player.get_playback_position())
		else:
			player.play()
		
		# 添加到激活列表
		if not layer_id in active_layers:
			active_layers.append(layer_id)
		
		print("[InteractiveMusicController] 开始播放层级", layer_id)

# 停止特定层级
func stop_layer(layer_id):
	if layer_id in active_layers:
		var player = layer_players[layer_id]
		player.stop()
		
		# 从激活列表中移除
		active_layers.erase(layer_id)
		
		print("[InteractiveMusicController] 停止播放层级", layer_id)


# 设置层级的音乐文件
func set_layer_music(layer_id, music_stream):
	if layer_id in music_layers.keys():
		music_layers[layer_id] = music_stream
		print("[InteractiveMusicController] 设置层级", layer_id, "的音乐")
