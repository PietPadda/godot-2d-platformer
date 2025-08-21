# player/states/player_run.gd
extends State # class type

# enter run state
func enter():
	character.animated_sprite.play("run")
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
	if Input.get_axis("ui_left", "ui_right") == 0:
		return get_parent().get_node("Idle")
	if Input.is_action_pressed("block") and character.is_on_floor():
		return get_parent().get_node("Block")
	# We'll add the other states like Slash later.

	# Horizontal movement logic
	var direction = Input.get_axis("ui_left", "ui_right")
	
	var current_speed = character.stats.speed

	character.velocity.x = direction * current_speed * character.speed_modifier
	character.animated_sprite.flip_h = direction < 0
	
	if direction != 0:
		character.animated_sprite.flip_h = direction < 0

	character.move_and_slide()
	return null
