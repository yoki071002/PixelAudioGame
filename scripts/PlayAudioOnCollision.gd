extends Area2D

@export var audio_clip: AudioStream
@export var audio_type: String = "default"  # Audio category (e.g., "effect", "dialogue")

# Dictionary to track audio players by type
var audio_players: Dictionary = {}

func _ready():
	# Ensure a player exists for the audio type
	if not audio_players.has(audio_type):
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		audio_players[audio_type] = player

	# Connect the signal
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		play_audio()

func play_audio():
	var player = audio_players[audio_type]

	# Stop the previous audio of the same type
	if player.playing:
		player.stop()

	# Assign the new clip and play
	player.stream = audio_clip
	player.play()
