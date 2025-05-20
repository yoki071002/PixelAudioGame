extends Area2D

@export var audio_clip: AudioStream
@export var audio_type: String = "default"  # Audio category (e.g., "narration", "effect")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		play_audio()

func play_audio():
	if not audio_clip:
		printerr("PlayAudioOnCollision: audio_clip is null.")
		return

	var file_name = audio_clip.resource_path.get_file()
	var determined_type = "sfx"  # Default type, also for UI_ prefixes for now

	if file_name.begins_with("UI_"):
		determined_type = "sfx" 
		# AudioManager currently doesn't have a dedicated "ui" type.
		# UI_ sounds will be played on the SFX bus via AudioManager unless AudioManager is updated.
		print("PlayAudioOnCollision: Playing UI_ prefixed sound '%s' via SFX type." % file_name)
	elif file_name.begins_with("SFX_"):
		determined_type = "sfx"
	elif file_name.begins_with("MS_"):
		determined_type = "music"
	elif file_name.begins_with("VO_"):
		determined_type = "narration"
	
	# The @export var audio_type is now effectively overridden by filename logic.
	# Consider removing or repurposing @export var audio_type if it's no longer used.
	AudioManager.play_audio(audio_clip, determined_type)
