# ui.win_screen.gd

extends Control

# paths
const MAIN_MENU = "res://ui/main_menu.tscn"

# Press the ReturnButton
func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU) # back to menu
