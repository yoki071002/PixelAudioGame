extends Camera2D

const TILE_SIZE = Vector2(32, 32);
const TILE_COUNT = Vector2(8, 12);

func _ready():
	# activate
	position = Vector2(64, -96);
	make_current();
	print("Active status:", is_current());
	print("Camera position:", position)

	# get the size of the browser
	var screen_size = get_viewport().get_visible_rect().size
	
