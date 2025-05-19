extends Area2D

@export var audio_clip: AudioStream
@onready var audio_player = AudioStreamPlayer2D.new()

func _ready():
	add_child(audio_player)
	audio_player.stream = audio_clip
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		if not audio_player.playing:
			audio_player.play()
