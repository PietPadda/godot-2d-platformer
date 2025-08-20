# enemies/skeleton.gd

extends "res://enemies/base_enemy.gd" # inherited base class

# ran when instance created
func _ready() -> void:
	# first run parenet's ready((
	super() # parent ready
	
	# Bat Overrides
	speed = 240 # increase speed
	gravity = 0 # no grav for bats!
