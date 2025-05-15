extends Node

signal beat_tick

@export var beat_interval := 0.375
var time := 0.0

func _process(delta):
	time += delta
	if time >= beat_interval:
		time -= beat_interval
		emit_signal("beat_tick")
