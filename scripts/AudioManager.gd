extends Node

var audio_players: Dictionary = {}

func play_audio(audio_type: String, audio_clip: AudioStream, parent: Node) -> void:
	if not audio_players.has(audio_type):
		var new_player := AudioStreamPlayer2D.new()
		new_player.name = audio_type
		new_player.global_position = parent.global_position
		parent.add_child(new_player)
		audio_players[audio_type] = new_player

	var audio_player: AudioStreamPlayer2D = audio_players[audio_type]

	if audio_player.playing:
		audio_player.stop()

	audio_player.stream = audio_clip
	audio_player.play()
