extends Node

# 当前关卡编号 (1-5)
@export var current_level: int = 1

# 玩家的总Coin数量
static var total_coins: int = 0

# 每关需要的解锁Coin数量
static var coins_required = [0, 5, 15, 30, 50]  # 第一关0个coin，第二关需要5个...

# 每关获胜获得的Coin数量
static var coins_reward = [5, 10, 15, 20, 25]

# 在关卡完成时调用此函数
func complete_level(add_coins: bool = true):
	print("关卡 %d 完成!" % current_level)
	
	# 添加Coin奖励
	if add_coins and current_level >= 1 and current_level <= 5:
		add_coins(coins_reward[current_level - 1])
	
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

# 添加Coin
static func add_coins(amount: int):
	total_coins += amount
	print("获得 %d 个Coin，现在总共有 %d 个Coin" % [amount, total_coins])
	save_coins()

# 检查是否有足够的Coin解锁特定关卡
static func has_enough_coins_for_level(level_index: int) -> bool:
	if level_index < 0 or level_index >= coins_required.size():
		return false
	return total_coins >= coins_required[level_index]

# 保存Coin数据
static func save_coins():
	var config = ConfigFile.new()
	config.set_value("player", "total_coins", total_coins)
	config.save("user://player_data.cfg")

# 加载Coin数据
static func load_coins():
	var config = ConfigFile.new()
	var err = config.load("user://player_data.cfg")
	if err == OK:
		total_coins = config.get_value("player", "total_coins", 0)
	else:
		total_coins = 0
		save_coins()
	print("加载Coin数据：当前拥有 %d 个Coin" % total_coins) 
