# ui/main_menu.gd

extends Control

# path to main game level
const GAME_SCENE_PATH = "res://game.tscn"

# press Play Game button
func _on_button_pressed() -> void:
	# tell scene tree to switch from menu to main game scene
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
