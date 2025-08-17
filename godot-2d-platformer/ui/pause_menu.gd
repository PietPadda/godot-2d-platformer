extends CanvasLayer

# paths
const MAIN_MENU = "res://ui/main_menu.tscn"

# resume button
func _on_resume_button_pressed() -> void:
	get_tree().paused = false # unpause game
	queue_free() # remove pause menu from scene

# quit button
func _on_quit_button_pressed() -> void:
	# IMPORTANT: Unpause before changing scenes, or  new scene will freeze
	get_tree().paused = false # unpause game
	# return to main menu
	get_tree().change_scene_to_file(MAIN_MENU)
