# player/states/player_fall.gd
extends State # class type

func enter():
	character.animated_sprite.play("jump")

func process_physics(delta) -> State:
	# If we land on the floor, transition to Idle
	if character.is_on_floor():
		return get_parent().get_node("Idle")

	# Handle double jump (which transitions back to the Jump state briefly)
	if Input.is_action_just_pressed("ui_accept") and character.jumps_left > 0:
		return get_parent().get_node("Jump")

	# Handle variable jump height
	if Input.is_action_just_released("ui_accept") and character.velocity.y < 0:
		character.velocity.y = 0

	# Apply gravity
	character.velocity.y += character.gravity * delta

	# Handle horizontal air control
	var direction = Input.get_axis("ui_left", "ui_right")
	var current_speed = character.stats.speed
	character.velocity.x = direction * current_speed * character.speed_modifier
	if direction != 0:
		character.animated_sprite.flip_h = direction < 0

	character.move_and_slide()
	return null
