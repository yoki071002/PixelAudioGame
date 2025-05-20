extends Node

# 用于访问主菜单的按钮
@onready var exit_menu_button = $"Exit Menu"
@onready var select_level_button = $Select
@onready var adjust_difficulty_button = $"Adjust Difficulty Press 2"
@onready var show_credits_button = $"Show Credits Press 3"
@onready var show_keyboard_mapping_button = $"Show Keyboard Mapping Press 4"
@onready var quit_game_button = $"Quit Game Press Control or command W"

# 音频播放器
var audio_player = AudioStreamPlayer.new()
var ui_sound

func _ready():
	
	# 连接按钮信号
	exit_menu_button.pressed.connect(_on_exit_menu_pressed)
	select_level_button.pressed.connect(_on_select_level_pressed)
	adjust_difficulty_button.pressed.connect(_on_adjust_difficulty_pressed)
	show_credits_button.pressed.connect(_on_show_credits_pressed)
	show_keyboard_mapping_button.pressed.connect(_on_show_keyboard_mapping_pressed)
	quit_game_button.pressed.connect(_on_quit_game_pressed)
	
	# 设置菜单音效
	load_menu_sound()
	add_child(audio_player)
	
	# 播放菜单音效
	audio_player.play()

func load_menu_sound():
	# 加载菜单音效
	ui_sound = load("res://Audio/UISounds/UI_Menu.wav")
	if ui_sound:
		audio_player.stream = ui_sound

func _input(event):
	# 键盘快捷键处理
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_on_select_level_pressed()
			KEY_2:
				_on_adjust_difficulty_pressed()
			KEY_3:
				_on_show_credits_pressed()
			KEY_4:
				_on_show_keyboard_mapping_pressed()
			KEY_W:
				if event.ctrl_pressed or event.meta_pressed:
					_on_quit_game_pressed()
	# 注意：ESC键处理已移至全局ESCMenuController

func _on_exit_menu_pressed():
	print("退出菜单")
	get_tree().paused = false
	# 使用全局控制器关闭菜单
	if has_node("/root/ESCMenuController"):
		get_node("/root/ESCMenuController").close_menu()
	else:
		# 向后兼容的处理
		get_parent().visible = false

func _on_select_level_pressed():
	print("重新开始并选择关卡")
	# 关闭菜单并取消暂停
	get_tree().paused = false
	if has_node("/root/ESCMenuController"):
		get_node("/root/ESCMenuController").close_menu()
	# 转到关卡选择菜单
	get_tree().change_scene_to_file("res://levels/level_select.tscn")

func _on_adjust_difficulty_pressed():
	print("调整难度")
	# 这里添加调整难度的代码
	# 例如: var difficulty_screen = load("res://scenes/difficulty_settings.tscn").instantiate()
	# add_child(difficulty_screen)

func _on_show_credits_pressed():
	print("显示制作人员")
	# 这里添加显示制作人员的代码
	# 例如: get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_show_keyboard_mapping_pressed():
	print("显示键盘映射")
	# 这里添加显示键盘映射的代码
	# 例如: var keyboard_map = load("res://scenes/keyboard_mapping.tscn").instantiate()
	# add_child(keyboard_map)

func _on_quit_game_pressed():
	print("退出游戏")
	get_tree().quit()
