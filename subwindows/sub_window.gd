extends Window
class_name SubWindow

@export var anchored_to_main_scene: bool = true
@export var window_anchor: EnumType.WindowAnchor
@export var pivot_point: Vector2 = Vector2()

@onready var drag_area: Control

var dragging: bool = false
var drag_start_pos: Vector2 = Vector2()

func _ready() -> void:
	drag_area.gui_input.connect(on_drag_area_input.bind())
	
func init() -> void:
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, true, get_window_id())
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_ALWAYS_ON_TOP, true, get_window_id())
	if DisplayServer.has_feature(DisplayServer.Feature.FEATURE_WINDOW_TRANSPARENCY):
		DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_TRANSPARENT, true, get_window_id())
		get_viewport().transparent_bg = true
	visible = false
	
func setup_window(to_screen_index: int, from_screen_index: int = 1) -> void :
	var new_usable_rect: Rect2 = DisplayServer.screen_get_usable_rect(to_screen_index)
	var old_usable_rect: Rect2 = DisplayServer.screen_get_usable_rect(from_screen_index)
	var size_ratio: Vector2 = Vector2(new_usable_rect.size) / Vector2(old_usable_rect.size)

	var old_pivot_position: Vector2 = Vector2(position) + pivot_point * Vector2(size)
	var new_pivot_position: Vector2 = Vector2(new_usable_rect.position) + Vector2(old_pivot_position - Vector2(old_usable_rect.position)) * size_ratio
	position = new_pivot_position - pivot_point * Vector2(size)

	save_window_position()
	
func save_window_position() -> void:
	pass
	
func get_saved_position() -> Vector2:
	return Vector2.ZERO
	
func on_drag_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		if event.pressed:
			drag_start_pos = event.position
		else:
			save_window_position()
	elif event is InputEventMouseMotion and dragging:
		var global_mouse_pos: Vector2 = Vector2(position) + event.position
		var new_pos: Vector2 = global_mouse_pos - drag_start_pos
		
		var usable_rect: Rect2 = DisplayServer.screen_get_usable_rect(WindowsManager.current_screen_index)
		new_pos.x = clamp(new_pos.x, usable_rect.position.x, usable_rect.end.x - size.x)
		new_pos.y = clamp(new_pos.y, usable_rect.position.y, usable_rect.end.y - size.y)
		
		position = new_pos

func open_window() -> void:
	var remembered_pos: Vector2 = get_saved_position()
	if remembered_pos != Vector2.ZERO:
		position = remembered_pos
	else:
		position = WindowsManager.get_appropriate_position(self)
	
	visible = true
	drag_area.mouse_filter = Control.MOUSE_FILTER_PASS
	if !drag_area.gui_input.is_connected(on_drag_area_input.bind()):
		drag_area.gui_input.connect(on_drag_area_input.bind())
	
func close_window() -> void:
	visible = false
	
func toggle_window() -> void :
	if !visible:
		open_window()
	else:
		close_window()
