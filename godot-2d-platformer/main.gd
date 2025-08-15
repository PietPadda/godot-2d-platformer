extends Node2D

# preload scene we want to switch to for efficiency
const WIN_SCREEN = preload("res://ui/win_screen.tscn")

func _ready():
	# seed the random number gen using the sys clock
	randomize()
	# listen for global level_finished signal
	GameEvents.level_finished.connect(on_level_finished)

func on_level_finished():
	# change active scene to win screen
	get_tree().change_scene_to_packed(WIN_SCREEN)
