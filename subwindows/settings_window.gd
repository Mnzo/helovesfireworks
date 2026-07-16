extends SubWindow
class_name SettingsWindow

var settings_data: SettingsData:
	get:
		return GameManager.settings_data
		
@onready var master_volume: Control = $Control/ScrollContainer/VBoxContainer/L_MasterVolume/HS_MasterVolume
@onready var music_volume: Control = $Control/ScrollContainer/VBoxContainer/L_MusicVolume/HS_MusicVolume
@onready var sfx_volume: Control = $Control/ScrollContainer/VBoxContainer/L_SFXVolume/HS_SFXVolume
@onready var vsync_checkbox: Control = $Control/ScrollContainer/VBoxContainer/L_VSync/CB_VSync
@onready var screen_option: OptionButton = $Control/ScrollContainer/VBoxContainer/L_Screen/OB_Screen

func _ready() -> void:
	drag_area = $Control/Panel
	
	master_volume.value_changed.connect(on_master_volume_value_changed)
	music_volume.value_changed.connect(on_music_volume_value_changed)
	sfx_volume.value_changed.connect(on_sfx_volume_value_changed)
	
	populate_screen_dropdown()
	screen_option.item_selected.connect(on_screen_selected)
	
	SignalsManager.data_loaded.connect(on_data_loaded)
	
func open_window() -> void:
	super.open_window()
	
func close_window() -> void:
	WindowsManager.main_scene.hud.turn_off_adjust_hud()
	super.close_window()
	
func populate_screen_dropdown() -> void:
	var screen_count: int = DisplayServer.get_screen_count()
	screen_option.clear()
	for i in range(screen_count):
		screen_option.add_item("Screen %d" % (i + 1), i)
		
	screen_option.disabled = screen_count <= 1
	screen_option.select(WindowsManager.current_screen_index)

func save_window_position() -> void:
	settings_data.settings_window_pos = position
	SaveLoadManager.save_resource(settings_data, GameManager.SETTINGS_PATH)
	
func get_saved_position() -> Vector2:
	return settings_data.settings_window_pos
	
func on_drag_area_input(event: InputEvent) -> void:
	super.on_drag_area_input(event)
	save_window_position()
	
func on_data_loaded() -> void:
	master_volume.value = settings_data.master_volume
	music_volume.value = settings_data.music_volume
	sfx_volume.value = settings_data.sfx_volume
	vsync_checkbox.button_pressed = settings_data.vsync
	
func on_adjust_button_pressed() -> void:
	WindowsManager.main_scene.hud.toggle_adjust_hud()

func on_master_volume_value_changed(value: float) -> void:
	settings_data.master_volume = value
	
func on_music_volume_value_changed(value: float) -> void:
	settings_data.music_volume = value
	
func on_sfx_volume_value_changed(value: float) -> void:
	settings_data.sfx_volume = value

func on_cb_vsync_toggled(toggled_on: bool) -> void:
	settings_data.vsync = toggled_on
	
func on_screen_selected(index: int) -> void:
	WindowsManager.switch_screen(index)
