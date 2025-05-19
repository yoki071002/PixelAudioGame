extends Node2D

@export var audio_clip: AudioStream

@onready var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

func _ready():
	add_child(audio_player)
	audio_player.stream = audio_clip

	# Set initial volume to -80 dB
	audio_player.volume_db = -80

	# Play audio on awake
	audio_player.play()

	# Connect collision signal
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		# Set volume to -6 dB
		audio_player.volume_db = -6
