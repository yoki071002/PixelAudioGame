# AudioManager.gd
extends Node

var audio_players: Dictionary = {}

func play_audio(audio_type: String, audio_clip: AudioStream, parent: Node) -> void:
	if not audio_players.has(audio_type):
		var audio_player = AudioStreamPlayer2D.new()
		parent.add_child(audio_player)
		audio_players[audio_type] = audio_player

	var audio_player = audio_players[audio_type]

	if audio_player.playing:
		audio_player.stop()

	audio_player.stream = audio_clip
	audio_player.play()
