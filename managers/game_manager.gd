extends Node

const SETTINGS_PATH: String = SaveLoadManager.SAVE_FOLDER + "settings_save.tres"
var settings_data: SettingsData

func _ready() -> void:
	call_deferred("call_load")
	
func call_load() -> void:
	await get_tree().process_frame
	SignalsManager.data_loaded.emit()

func main_scene_ready() -> void:
	load_game()
	WindowsManager.init()
	
func load_game() -> void:
	settings_data = SaveLoadManager.try_load_resource(SETTINGS_PATH) as SettingsData
	if !settings_data:
		settings_data = SettingsData.new()
		SaveLoadManager.save_resource(settings_data, GameManager.SETTINGS_PATH)
