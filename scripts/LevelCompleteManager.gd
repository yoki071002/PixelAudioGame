extends Node

# 当前关卡编号 (1-5)
@export var current_level: int = 1

# 在关卡完成时调用此函数
func complete_level():
	print("关卡 %d 完成!" % current_level)
	
	# 解锁下一关
	unlock_next_level()
	
	# 返回选关菜单
	get_tree().change_scene_to_file("res://levels/level_select.tscn")

# 解锁下一关
func unlock_next_level():
	# 获取选关菜单的脚本实例，解锁下一关
	var level_select_script = load("res://scripts/SelectLevelsMenu.gd").new()
	level_select_script.unlock_next_level(current_level - 1) # 转换为0-4的索引
	
	print("已解锁关卡 %d" % (current_level + 1)) 
