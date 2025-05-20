extends Node

# ESC菜单场景路径
const ESC_MENU_SCENE = "res://levels/ESCMenu.tscn"

# 菜单实例
var esc_menu_instance = null
var is_menu_open = false

func _ready():
	# 确保菜单关闭时游戏不会暂停
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# 检测ESC键按下
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if is_menu_open:
			close_menu()
		else:
			open_menu()

# 打开ESC菜单
func open_menu():
	if is_menu_open:
		return
		
	# 创建菜单实例
	if esc_menu_instance == null:
		var menu_scene = load(ESC_MENU_SCENE)
		if menu_scene:
			esc_menu_instance = menu_scene.instantiate()
			# 添加到场景树中
			get_tree().root.add_child(esc_menu_instance)
		else:
			print("错误：无法加载ESC菜单场景")
			return
	
	# 设置菜单可见
	esc_menu_instance.visible = true
	is_menu_open = true
	
	# 暂停游戏
	get_tree().paused = true

# 关闭ESC菜单
func close_menu():
	if not is_menu_open or esc_menu_instance == null:
		return
		
	# 隐藏菜单而不是移除它
	esc_menu_instance.visible = false
	is_menu_open = false
	
	# 恢复游戏
	get_tree().paused = false 