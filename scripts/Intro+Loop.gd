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
	if first_clip and first_clip.resource_path:
		var file_name = first_clip.resource_path.get_file()
		if file_name.begins_with("UI_"): audio_player.bus = "UI"
		elif file_name.begins_with("SFX_"): audio_player.bus = "SFX"
		elif file_name.begins_with("MS_"): audio_player.bus = "MusicBus"
		elif file_name.begins_with("VO_"): audio_player.bus = "Narration"
		# else: default bus (Master)
	audio_player.play()

func _on_audio_finished():
	# Switch to the second clip when the first finishes
	if audio_player.stream == first_clip:
		audio_player.stream = second_clip
		if second_clip and second_clip.resource_path:
			var file_name = second_clip.resource_path.get_file()
			if file_name.begins_with("UI_"): audio_player.bus = "UI"
			elif file_name.begins_with("SFX_"): audio_player.bus = "SFX"
			elif file_name.begins_with("MS_"): audio_player.bus = "MusicBus"
			elif file_name.begins_with("VO_"): audio_player.bus = "Narration"
			# else: default bus (Master)
		audio_player.play()
