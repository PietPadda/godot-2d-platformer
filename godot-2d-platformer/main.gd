extends Node2D

# preload scene we want to switch to for efficiency
const WIN_SCREEN = preload("res://ui/win_screen.tscn")
const PAUSE_MENU = preload("res://ui/pause_menu.tscn")

func _ready():
	# seed the random number gen using the sys clock
	randomize()
	# listen for global level_finished signal
	GameEvents.level_finished.connect(on_level_finished)

func on_level_finished():
	# change active scene to win screen
	get_tree().change_scene_to_packed(WIN_SCREEN)

# _unhandled_input is checked after normal game input
# best place for pause-like actions
func _unhandled_input(event):
	if event.is_action_pressed("pause"): # Escape pressed
		# create instance of pause menu scene
		var pause_menu_instance = PAUSE_MENU.instantiate()
		# add to the main scene
		add_child(pause_menu_instance)
		# pause the entire game
		get_tree().paused = true
