extends Control

func _ready():
	# 默认情况下隐藏菜单
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _input(event):
	# 当按下ESC键时显示/隐藏菜单
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle_menu()

func toggle_menu():
	visible = !visible
	get_tree().paused = visible 