# enemies/skeleton.gd

extends "res://enemies/base_enemy.gd" # inherited base class

# ran when instance created
func _ready() -> void:
	# first run parenet's ready((
	super() # parent ready
	
	# Skeleton Overrides
	speed = 60 # increase speed
	$ShootTimer.wait_time = 2 # update shoot time
