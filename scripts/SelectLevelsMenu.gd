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
	
	# 更新按钮状态
	update_button_states()
	
	# 播放选关菜单音效
	play_sound(select_sound)

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
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_level_button_pressed(level_index):
	if unlocked_levels[level_index]:
		print("开始关卡 " + str(level_index + 1))
		
		# 播放开始关卡音效
		play_sound(start_level_sound)
		
		# 等待音效播放完毕
		await audio_player.finished
		
		# 播放相应数字音效
		play_sound(number_sounds[level_index])
		
		# 等待数字音效播放完毕后加载关卡
		await audio_player.finished
		
		# 加载相应关卡
		get_tree().change_scene_to_file("res://levels/level" + str(level_index + 1) + ".tscn")
	else:
		print("关卡已锁定")
		# 播放锁定警告音效
		play_sound(level_locked_warning_sound)
		
		# 显示锁定警告
		show_level_locked_warning()

func show_level_locked_warning():
	# 在此处实现警告显示逻辑
	# 可以使用对话框或UI元素显示警告
	var warning_dialog = AcceptDialog.new()
	warning_dialog.title = "关卡锁定"
	warning_dialog.dialog_text = "您选择的关卡已锁定。请先通关前面已解锁的关卡来解锁下一关！"
	add_child(warning_dialog)
	warning_dialog.popup_centered()

# 用于外部调用解锁下一关
func unlock_next_level(current_level):
	if current_level >= 0 and current_level < 4:  # 只有4关可以解锁下一关
		unlocked_levels[current_level + 1] = true
		update_button_states()
		# 保存解锁状态到配置文件或游戏存档
		save_unlocked_levels()

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
		update_button_states()
