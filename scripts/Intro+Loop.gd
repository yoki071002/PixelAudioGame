extends Node

@export var first_clip: AudioStream
@export var second_clip: AudioStream

var audio_player: AudioStreamPlayer2D

func _ready():
	# Create and add the audio player to the scene
	audio_player = AudioStreamPlayer2D.new()
	add_child(audio_player)

	# Connect the finished signal
	audio_player.finished.connect(_on_audio_finished)

	# Start with the first clip
	audio_player.stream = first_clip
	audio_player.play()

func _on_audio_finished():
	# Switch to the second clip when the first finishes
	if audio_player.stream == first_clip:
		audio_player.stream = second_clip
		audio_player.play()
