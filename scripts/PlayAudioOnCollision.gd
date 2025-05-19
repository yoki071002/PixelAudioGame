extends Area2D

@export var audio_clip: AudioStream
@export var audio_type: String = "default"  # Audio category (e.g., "narration", "effect")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		play_audio()

func play_audio():
	AudioManager.play_audio(audio_type, audio_clip, self)
