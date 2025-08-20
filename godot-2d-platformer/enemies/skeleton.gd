# enemies/skeleton.gd

extends "res://enemies/base_enemy.gd" # inherited base class

# ran when instance created
func _ready() -> void:
	# first run parenet's ready()
	super() # parent ready
	
	# Skeleton Overrides
	$ShootTimer.wait_time = stats.fire_rate # update shoot time
