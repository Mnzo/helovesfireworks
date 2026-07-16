extends Node

signal ready_instantiate_window()

const WINDOW_SIZE = Vector2i(512, 512)
const ANCHOR_FRACTIONS: Dictionary = {
	EnumType.WindowAnchor.TOP_LEFT: Vector2(0, 0),
	EnumType.WindowAnchor.TOP_CENTER: Vector2(0.5, 0),
	EnumType.WindowAnchor.TOP_RIGHT: Vector2(1, 0),
	EnumType.WindowAnchor.CENTER_LEFT: Vector2(0, 0.5),
	EnumType.WindowAnchor.CENTER: Vector2(0.5, 0.5),
	EnumType.WindowAnchor.CENTER_RIGHT: Vector2(1, 0.5),
	EnumType.WindowAnchor.BOTTOM_LEFT: Vector2(0, 1),
	EnumType.WindowAnchor.BOTTOM_CENTER: Vector2(0.5, 1),
	EnumType.WindowAnchor.BOTTOM_RIGHT: Vector2(1, 1),
	EnumType.WindowAnchor.NONE: Vector2(0.5, 0.5),
}

var monitor_size: Vector2
var main_window_id: int = DisplayServer.get_window_list()[0]
var camera: Camera2D
var main_scene: MainScene

var current_screen_index: int = 0

var settings_window: SettingsWindow = null

var all_windows: Array[SubWindow]

func init() -> void:
	setup_main_window()
	main_scene = get_tree().get_root().get_node("TestMap")
	setup_sub_windows()
	ready_instantiate_window.emit()
	
func setup_main_window() -> void:
	DisplayServer.window_set_current_screen(0, main_window_id)
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, true, main_window_id)
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_ALWAYS_ON_TOP, true, main_window_id)

	if DisplayServer.has_feature(DisplayServer.Feature.FEATURE_WINDOW_TRANSPARENCY):
		DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_TRANSPARENT, true, main_window_id)
		get_viewport().transparent_bg = true

	if GameManager.settings_data.screen_index >= 0 \
	and GameManager.settings_data.screen_index < DisplayServer.get_screen_count():
		current_screen_index = GameManager.settings_data.screen_index
	else:
		current_screen_index = DisplayServer.get_primary_screen()
	
	setup_main_window_size_position(current_screen_index)

func setup_main_window_size_position(screen_index: int) -> void:
	if GameManager.settings_data.window_size != Vector2.ZERO and GameManager.settings_data.window_pos != Vector2.ZERO:
		DisplayServer.window_set_size(GameManager.settings_data.window_size, main_window_id)
		DisplayServer.window_set_position(GameManager.settings_data.window_pos, main_window_id)
	else:
		var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen_index)
		monitor_size = Vector2(usable_rect.size)
		
		var window_x_position: float = usable_rect.position.x + (usable_rect.size.x / 2.0) - (WINDOW_SIZE.x / 2.0)
		var window_y_position: float = usable_rect.position.y + usable_rect.size.y - WINDOW_SIZE.y

		DisplayServer.window_set_size(WINDOW_SIZE, main_window_id)
		DisplayServer.window_set_position(Vector2(window_x_position, window_y_position), main_window_id)
	
	setup_centered_camera()
	
func setup_centered_camera() -> void:
	camera = get_viewport().get_camera_2d()
	if camera:
		camera.zoom = Vector2(1.0, 1.0)
		camera.position = Vector2(WINDOW_SIZE) / 2.0
		
func setup_sub_windows() -> void:
	await get_tree().process_frame
	get_viewport().set_embedding_subwindows(false)
	settings_window = instantiate_window("res://subwindows/settings_window.tscn")
	
func instantiate_window(scene_path: String) -> SubWindow:
	var scene: PackedScene = load(scene_path)
	var sub_window: SubWindow = scene.instantiate()
	get_tree().root.add_child(sub_window)
	sub_window.init()
	all_windows.append(sub_window)
	return sub_window

func get_appropriate_position(sub_window: SubWindow) -> Vector2:
	var reference_rect: Rect2 = get_reference_rect(sub_window.anchored_to_main_scene)
	var anchor_fraction: Vector2 = ANCHOR_FRACTIONS[sub_window.window_anchor]
	
	var anchor_position: Vector2 = Vector2(reference_rect.position) + Vector2(reference_rect.size) * anchor_fraction
	var position: Vector2 = anchor_position - Vector2(sub_window.size) * sub_window.pivot_point
	
	var usable_rect: Rect2 = DisplayServer.screen_get_usable_rect(current_screen_index)
	if usable_rect.intersects(Rect2(position, sub_window.window_rect.size)):
		return position
	else:
		return Vector2(usable_rect.position) + Vector2(usable_rect.size) / 2.0 - sub_window.window_rect.size / 2.0

func get_reference_rect(use_main_scene: bool) -> Rect2:
	if use_main_scene:
		return Rect2(
			DisplayServer.window_get_position(main_window_id),
			DisplayServer.window_get_size(main_window_id)
		)
	else:
		var usable_rect: Rect2 = DisplayServer.screen_get_usable_rect(current_screen_index)
		return Rect2(usable_rect.position, Vector2(usable_rect.size) - Vector2(0, GameManager.settings_data.window_size.y))
		
func switch_screen(to_screen_index: int) -> void:
	if to_screen_index == current_screen_index:
		return
	if to_screen_index < 0 or to_screen_index >= DisplayServer.get_screen_count():
		return
		
	var from_screen_index: int = current_screen_index
	current_screen_index = to_screen_index
	
	GameManager.settings_data.window_size = Vector2.ZERO
	GameManager.settings_data.window_pos = Vector2.ZERO
	setup_main_window_size_position(to_screen_index)
	
	for sub_window: SubWindow in all_windows:
		sub_window.setup_window(to_screen_index, from_screen_index)

	GameManager.settings_data.screen_index = to_screen_index
	SaveLoadManager.save_resource(GameManager.settings_data, GameManager.SETTINGS_PATH)
