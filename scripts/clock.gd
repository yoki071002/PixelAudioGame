extends Node

signal beat_tick

var beat_interval = 60/80/2
var time := 0.0

func _ready():
	print("[Clock] 初始化完成")
	print("[Clock] Beat Interval: ", beat_interval, " 秒")

func _process(delta):
	time += delta
	if time >= beat_interval:
		time -= beat_interval
		#print("[Clock] 发送节拍信号 - 当前时间: ", Time.get_ticks_msec()/1000.0)
		emit_signal("beat_tick")
