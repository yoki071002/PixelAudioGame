extends CollisionShape2D
@export var audio_file: AudioStream
@onready var audio_player = AudioStreamPlayer2D.new()

func _ready() -> void:
	add_child(audio_player)
	audio_player.stream = audio_file

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		if not audio_player.playing:
			audio_player.play()

func _on_body_exited(body: Node) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	pass

func _on_area_exited(area: Area2D) -> void:
	pass
