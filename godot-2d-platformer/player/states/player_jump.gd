# player/states/player_jump.gd
extends State # class type

func enter():
	# Apply the initial jump impulse and use one jump
	character.velocity.y = character.stats.jump_velocity
	character.jumps_left -= 1

	character.sfx_player.stream = character.JUMP_SOUND
	character.sfx_player.play()

func process_physics(delta) -> State:
	# Immediately transition to the Fall state to handle the rest of the air physics
	return get_parent().get_node("Fall")
