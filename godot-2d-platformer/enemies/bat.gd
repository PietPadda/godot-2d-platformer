# enemies/bat.gd

extends "res://enemies/base_enemy.gd"

# called when the Bat is created
func _ready():
	# call super() to run the _ready() function from our base_enemy script
	super()
	# Bats don't care about gravity
	gravity = 0 # zero grav

# We are OVERRIDING the patrol_state function from the base script
func patrol_state(delta):
	# when patrolling, the bat will just hover in place
	velocity = velocity.lerp(Vector2.ZERO, 0.05) # x=0, y "lerps" up and down to hover
	animated_sprite.play("sleep") # use the bat's "sleep" animation.
	move_and_slide() # magic physics

# We are also OVERRIDING the chase_state function.
func chase_state(delta):
	# edge case no player? just patrol
	if not is_instance_valid(player):
		state = PATROL
		return # early exit
	
	# fly directly towards the player
	var direction_to_player = (player.global_position - global_position).normalized()
	velocity = direction_to_player * speed * 4.0 # fly a bit faster than a walking mob.
	
	animated_sprite.flip_h = velocity.x < 0 # flip sprite
	animated_sprite.play("fly") # play our chase state animation
	move_and_slide()
