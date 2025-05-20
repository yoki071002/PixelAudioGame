extends Node

# 按钮引用
@onready var exit_menu_button = $"Exit Menu"
@onready var level1_button = $"Level 1 Press 1"
@onready var level2_button = $"2 for Level 2" 
@onready var level3_button = $"3 for Level 3"
@onready var level4_button = $"4 for Level 4"
@onready var level5_button = $"5 for Level 5"

# 音频播放器
var audio_player = AudioStreamPlayer.new()
var select_sound
var start_level_sound
var number_sounds = []
var level_locked_warning_sound

# 关卡解锁状态 (初始只解锁第一关)
var unlocked_levels = [true, false, false, false, false]
var loading_level = false

# Coin显示标签
@onready var coins_label = $CoinsLabel

func _ready():
	# 连接按钮信号
	exit_menu_button.pressed.connect(_on_exit_menu_pressed)
	level1_button.pressed.connect(func(): _on_level_button_pressed(0))
	level2_button.pressed.connect(func(): _on_level_button_pressed(1))
	level3_button.pressed.connect(func(): _on_level_button_pressed(2))
	level4_button.pressed.connect(func(): _on_level_button_pressed(3))
	level5_button.pressed.connect(func(): _on_level_button_pressed(4))
	
	# 加载音效
	load_sounds()
	add_child(audio_player)
	
	# 加载游戏进度
	load_unlocked_levels()
	
	# 加载Coin数据
	load_coin_data()
	
	# 更新按钮状态
	update_button_states()
	
	# 播放选关菜单音效
	play_sound(select_sound)

func load_coin_data():
	# 从LevelCompleteManager加载Coin数据
	var lcm = load("res://scripts/LevelCompleteManager.gd")
	lcm.load_coins()
	
	# 更新UI显示
	if coins_label:
		coins_label.text = "金币: %d" % lcm.total_coins

func load_sounds():
	# 加载所有音效
	select_sound = load("res://Audio/UISounds/UI_LevelSelect.wav")
	start_level_sound = load("res://Audio/UISounds/UI_StartLevel.wav")
	level_locked_warning_sound = load("res://Audio/UISounds/UI_LevelLockedWarning.wav")
	
	# 加载1-5的数字音效
	for i in range(1, 6):
		var number_sound = load("res://Audio/UISounds/UI_0" + str(i) + ".wav")
		number_sounds.append(number_sound)

func play_sound(sound):
	if sound:
		audio_player.stream = sound
		audio_player.play()

func update_button_states():
	# 根据解锁状态更新按钮
	level1_button.disabled = !unlocked_levels[0]
	level2_button.disabled = !unlocked_levels[1]
	level3_button.disabled = !unlocked_levels[2]
	level4_button.disabled = !unlocked_levels[3]
	level5_button.disabled = !unlocked_levels[4]
	
	# 更新按钮提示文本，显示需要的Coin数量
	var lcm = load("res://scripts/LevelCompleteManager.gd")
	
	# 为每个锁定的关卡添加所需金币提示
	if !unlocked_levels[1] and has_node("2 for Level 2/RequiredCoins"):
		get_node("2 for Level 2/RequiredCoins").text = "需要 %d 金币" % lcm.coins_required[1]
	
	if !unlocked_levels[2] and has_node("3 for Level 3/RequiredCoins"):
		get_node("3 for Level 3/RequiredCoins").text = "需要 %d 金币" % lcm.coins_required[2]
	
	if !unlocked_levels[3] and has_node("4 for Level 4/RequiredCoins"):
		get_node("4 for Level 4/RequiredCoins").text = "需要 %d 金币" % lcm.coins_required[3]
	
	if !unlocked_levels[4] and has_node("5 for Level 5/RequiredCoins"):
		get_node("5 for Level 5/RequiredCoins").text = "需要 %d 金币" % lcm.coins_required[4]

func _input(event):
	# 按键选择关卡
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_on_exit_menu_pressed()
			KEY_1:
				_on_level_button_pressed(0)
			KEY_2:
				_on_level_button_pressed(1)
			KEY_3:
				_on_level_button_pressed(2)
			KEY_4:
				_on_level_button_pressed(3)
			KEY_5:
				_on_level_button_pressed(4)

func _on_exit_menu_pressed():
	print("返回主菜单")
	# 回到主菜单
	get_tree().change_scene_to_file("res://levels/ESCMenu.tscn")

func _on_level_button_pressed(level_index):
	if loading_level:
		return  # Prevent re-entry if a level is already loading

	# 检查关卡是否已解锁
	if unlocked_levels[level_index]:
		loading_level = true  # Set flag to prevent further input
		print("开始关卡 " + str(level_index + 1))
		
		# 播放开始关卡音效
		play_sound(start_level_sound)
		await audio_player.finished
		
		# 播放相应数字音效
		play_sound(number_sounds[level_index])
		await audio_player.finished
		
		# 加载相应关卡
		get_tree().change_scene_to_file("res://levels/level" + str(level_index + 1) + ".tscn")
	else:
		# 检查是否有足够的Coin
		var lcm = load("res://scripts/LevelCompleteManager.gd")
		if lcm.has_enough_coins_for_level(level_index):
			# 解锁关卡
			unlocked_levels[level_index] = true
			save_unlocked_levels()
			update_button_states()
			
			print("使用金币解锁关卡 " + str(level_index + 1))
			play_sound(start_level_sound)
		else:
			print("关卡已锁定，金币不足")
		play_sound(level_locked_warning_sound)
		show_level_locked_warning(level_index)

func show_level_locked_warning(level_index = -1):
	# 在此处实现警告显示逻辑
	var lcm = load("res://scripts/LevelCompleteManager.gd")
	var warning_dialog = AcceptDialog.new()
	warning_dialog.title = "关卡锁定"
	
	if level_index >= 0 and level_index < lcm.coins_required.size():
		warning_dialog.dialog_text = "您选择的关卡已锁定。\n需要 %d 个金币才能解锁此关卡。\n您当前拥有 %d 个金币。" % [
			lcm.coins_required[level_index],
			lcm.total_coins
		]
	else:
		warning_dialog.dialog_text = "您选择的关卡已锁定。请先通关前面已解锁的关卡来获取更多金币！"
	
	add_child(warning_dialog)
	warning_dialog.popup_centered()

# 用于外部调用解锁下一关
func unlock_next_level(current_level_completed_index: int): # 参数是刚完成的关卡的索引 (0-indexed)
	# 确保要解锁的下一关卡的索引是有效的
	if current_level_completed_index >= 0 and current_level_completed_index < (unlocked_levels.size() - 1):
		var next_level_to_unlock_index = current_level_completed_index + 1
		
		# 在进行修改前，从文件加载最新的解锁状态
		# 这很重要，因为此实例中的 'unlocked_levels' 数组可能已过时
		# (如果它是一个新创建的实例，而不是来自场景树)。
		load_unlocked_levels() 
		
		# 仅当下一关尚未解锁时才继续
		if not unlocked_levels[next_level_to_unlock_index]:
			unlocked_levels[next_level_to_unlock_index] = true
			save_unlocked_levels() # 将修改后的 'unlocked_levels' 数组保存到文件
		
		# 仅当此脚本实例是活动场景树的一部分时，才尝试更新UI元素。
		# 这可以防止在此函数被游离实例调用时出错 (例如，从LevelCompleteManager调用)。
		if is_inside_tree():
			update_button_states()


func save_unlocked_levels():
	# 在此处实现存档逻辑，例如使用ConfigFile
	var config = ConfigFile.new()
	for i in range(5):
		config.set_value("levels", "level" + str(i + 1) + "_unlocked", unlocked_levels[i])
	config.save("user://level_progress.cfg")

func load_unlocked_levels():
	# 从存档加载解锁状态
	var config = ConfigFile.new()
	var err = config.load("user://level_progress.cfg")
	if err == OK:
		for i in range(5):
			unlocked_levels[i] = config.get_value("levels", "level" + str(i + 1) + "_unlocked", i == 0) # 默认只解锁第一关
	else:
		# 确保第一关始终解锁
		unlocked_levels[0] = true
