extends Sprite2D

@export_range(0.0, 1.0) var transparency: float = 1.0  # 1.0 = fully opaque, 0.0 = fully transparent

func _ready():
	update_transparency()

func update_transparency():
	# Keep the original color, change only alpha
	modulate.a = transparency

# Optional: dynamically update if you change `transparency` at runtime
func _process(_delta):
	update_transparency()
