extends Node

# preload scene we want to switch to for efficiency
const WIN_SCREEN = preload("res://ui/win_screen.tscn")
const PAUSE_MENU = preload("res://ui/pause_menu.tscn")

# variables
var current_level

func _ready():
	# seed the random number gen using the sys clock
	randomize()
	# listen for global level_finished signal
	GameEvents.level_finished.connect(on_level_finished)
	# load our first level when the game starts
	load_level("res://levels/level_1.tscn")

# called with level_finished signal
func on_level_finished():
	# change active scene to win screen
	get_tree().change_scene_to_packed(WIN_SCREEN)

# _unhandled_input is checked after normal game input
# best place for pause-like actions
func _unhandled_input(event):
	# pause handling
	if event.is_action_pressed("pause"): # Escape pressed
		# multiple pause edge case
		if not get_tree().paused and find_child("PauseMenu"):
			return # early exit
		
		# create instance of pause menu scene
		var pause_menu_instance = PAUSE_MENU.instantiate()
		# add to the main scene
		add_child(pause_menu_instance)
		# pause the entire game
		get_tree().paused = true

# load any level we give it
func load_level(level_path):
	var level_scene = load(level_path) # set level scene
	current_level = level_scene.instantiate() # create level instance
	add_child(current_level) # add instannce as child
