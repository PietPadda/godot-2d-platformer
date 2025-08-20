# game.gd

extends Node

# preload scene we want to switch to for efficiency
const WIN_SCREEN = preload("res://ui/win_screen.tscn")
const PAUSE_MENU = preload("res://ui/pause_menu.tscn")

# variables
# level scenes array
var level_scenes = [
	"res://levels/level_1.tscn",
	"res://levels/level_2.tscn"
]
var current_level_index = 0 # init at first scene
var current_level_instance # track current scene

func _ready():
	# seed the random number gen using the sys clock
	randomize()
	GameEvents.current_score = 0 # reset score on new game
	print("New game started! Player health set to: ", GameEvents.current_health) # DEBUG
	# listen for global level_finished signal
	GameEvents.level_finished.connect(on_level_finished)
	# load current level instance
	load_level()
	
	# announce all initialization complete
	GameEvents.game_ready.emit()

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

# load current level index
func load_level():
	# clear current level instance
	if is_instance_valid(current_level_instance):
		current_level_instance.call_deferred("queue_free")
	
	# get next level path
	var level_path = level_scenes[current_level_index]
	var level_scene = load(level_path) # set level scene
	current_level_instance  = level_scene.instantiate() # create level instance
	call_deferred("add_child", current_level_instance) # add instannce as child

# called with level_finished signal
func on_level_finished():
	# set next level on finish
	current_level_index += 1 # incr
	
	# check if more levels left
	if current_level_index < level_scenes.size(): # still levels left
		# load next level
		load_level()
	else: # we've reach the end
		# change active scene to win screen
		get_tree().call_deferred("change_scene_to_packed", WIN_SCREEN)
