# AudioManager.gd
extends Node

var audio_players: Dictionary = {}

func play_audio(audio_type: String, audio_clip: AudioStream, parent: Node) -> void:
	if not audio_players.has(audio_type):
		var player = AudioStreamPlayer2D.new()
		parent.add_child(player)
		audio_players[audio_type] = player

	var player = audio_players[audio_type]

	if player.playing:
		player.stop()

	player.stream = audio_clip
	player.play()
