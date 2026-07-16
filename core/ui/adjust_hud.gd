extends CanvasLayer
class_name AdjustHUD

var resizing: bool = false
var current_window_size: Vector2 = Vector2()
var current_window_pos: Vector2 = Vector2()

func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseMotion):
		return
	
	if resizing:
		var win_id: int = DisplayServer.get_window_list()[0]
		var size: Vector2 = DisplayServer.window_get_size(win_id)
		var pos: Vector2 = DisplayServer.window_get_position(win_id)
		var screen_idx: int = DisplayServer.window_get_current_screen(win_id)
		var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen_idx)
		var min_width: float = 256.0
		var mouse_pos: Vector2 = DisplayServer.mouse_get_position()
		
		var bottom_edge: float = pos.y + size.y
		var right_edge: float = pos.x + size.x
		
		var max_height_before_top: float = bottom_edge - usable_rect.position.y
		var max_width_before_left: float = right_edge - usable_rect.position.x
		var max_size: float = min(max_height_before_top, max_width_before_left)
		
		var new_width: float = clamp(pos.x + size.x - mouse_pos.x, min_width, max_size)
		var new_height: float = new_width
		var new_x: float = pos.x + (size.x - new_width)
		var new_y: float = pos.y + (size.y - new_height)
		current_window_size = Vector2(new_width, new_height)
		current_window_pos = Vector2(new_x, new_y)
		@warning_ignore("narrowing_conversion")
		DisplayServer.window_set_size(current_window_size, win_id)
		@warning_ignore("narrowing_conversion")
		DisplayServer.window_set_position(current_window_pos, win_id)

func on_resize_button_down() -> void:
	resizing = true

func on_resize_button_up() -> void:
	resizing = false
	GameManager.settings_data.window_size = current_window_size
	GameManager.settings_data.window_pos = current_window_pos
	SaveLoadManager.save_resource(GameManager.settings_data, GameManager.SETTINGS_PATH)
