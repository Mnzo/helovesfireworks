extends Control
class_name HUDController

@export var adjust_hud: Node

func turn_on_adjust_hud() -> void:
	adjust_hud.visible = true

func turn_off_adjust_hud() -> void:
	adjust_hud.visible = false
	
func toggle_adjust_hud() -> void:
	if adjust_hud.visible == true:
		turn_off_adjust_hud()
	else:
		turn_on_adjust_hud()
