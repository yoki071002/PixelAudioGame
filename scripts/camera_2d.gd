extends Camera2D

const TILE_SIZE = Vector2(32, 32);
const TILE_COUNT = Vector2(8, 12);

func _ready():
	# activate
	var map_size = TILE_SIZE * TILE_COUNT;
	position = map_size / 2;
	make_current();
	print("Active status:", is_current());
	print("Camera position:", position)

	# get the size of the browser
	var screen_size = get_viewport().get_visible_rect().size
	
	# zoom ratio needed to fit the whole map
	var zoom_x = screen_size.x / map_size.x
	var zoom_y = screen_size.y / map_size.y
	
	# choose the smaller one so the whole map fits
	var target_zoom = min(zoom_x, zoom_y)

	zoom = Vector2(0.2, 0.2)
	print("Screen size:", screen_size, " | Map size:", map_size, " | Zoom:", zoom)
