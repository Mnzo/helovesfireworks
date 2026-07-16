extends Node
class_name MainScene

@export var hud: HUDController

func _ready() -> void:
	GameManager.main_scene_ready()

func _on_button_pressed() -> void:
	SaveLoadManager.save_resource(GameManager.settings_data, GameManager.SETTINGS_PATH)
	WindowsManager.settings_window.toggle_window()
