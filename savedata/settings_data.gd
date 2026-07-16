extends Resource
class_name SettingsData

@export var master_volume: float = 100.0
@export var music_volume: float = 50.0
@export var sfx_volume: float = 100.0
@export var vsync: bool = true
@export var window_size: Vector2
@export var window_pos: Vector2
@export var screen_index: int = -1
@export var settings_window_pos: Vector2

func _init() -> void:
	pass
