extends Area2D

@export var audio_clip: AudioStream
@export var audio_type: String = ""  # 音频类别（可以留空，由AudioManager自动检测）
@export var play_on_ready = true
@export var delay_seconds: float = 0.0
@export var audio_pitch: float = 1.0  # 音高缩放

func _ready():
	if play_on_ready:
		if delay_seconds > 0:
			await get_tree().create_timer(delay_seconds).timeout
		play_audio()

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		play_audio()

func play_audio():
	if audio_clip:
		var file_name = audio_clip.resource_path.get_file()
		var determined_type = "sfx"  # Default type

		if file_name.begins_with("UI_"):
			determined_type = "sfx" # AudioManager currently doesn't have a dedicated "ui" type.
			print("PlayAudioOnAwake: Playing UI_ prefixed sound '%s' via SFX type." % file_name)
		elif file_name.begins_with("SFX_"):
			determined_type = "sfx"
		elif file_name.begins_with("MS_"):
			determined_type = "music"
		elif file_name.begins_with("VO_"):
			determined_type = "narration"
		
		# The @export var audio_type is now effectively overridden by filename logic.
		AudioManager.play_audio(audio_clip, determined_type, audio_pitch)
	else:
		printerr("PlayAudioOnAwake: No audio clip assigned to ", name)
