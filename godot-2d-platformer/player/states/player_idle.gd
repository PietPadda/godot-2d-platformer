# player/states/player_idle.gd
extends State # class type

# enter idle state
func enter():
	character.animated_sprite.play("idle")
	# resets jumps when we return to an idle state on the ground
	if character.is_on_floor():
		character.jumps_left = 2

func process_physics(delta) -> State:
	# Transition to Fall state if we walk off a ledge
	if not character.is_on_floor():
		return get_parent().get_node("Fall")

	# Transition to other states based on input
	if Input.is_action_just_pressed("ui_accept"):
		return get_parent().get_node("Jump")
	if Input.get_axis("ui_left", "ui_right") != 0:
		return get_parent().get_node("Run")
	# We'll add the other states like Slash later.

	# Apply physics (friction)
	character.velocity.x = lerp(character.velocity.x, 0.0, 0.2)
	character.move_and_slide()

	return null # Stay in this state
