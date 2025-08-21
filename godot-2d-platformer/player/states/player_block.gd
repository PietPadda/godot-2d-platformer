# player/states/player_block.gd
extends State # class type

func enter():
	# when enter block state, activate  shield
	character.shield.visible = true
	character.get_node("Shield/CollisionShape2D").disabled = false
	character.animated_sprite.play("idle") # Or a dedicated block animation

func exit():
	# when leave block state, deactivate shield
	character.shield.visible = false
	character.get_node("Shield/CollisionShape2D").disabled = true

func process_physics(delta) -> State:
	# leave state by release block button
	if not Input.is_action_pressed("block"):
		return get_parent().get_node("Idle") # transition back to idle
	
	# apply grav in case we get knocked into the air while blocking
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta

	# Handle movement while blocking
	var direction = Input.get_axis("ui_left", "ui_right")
	# get the block speed multiplier from the stats resource
	var block_speed = character.stats.speed * character.stats.block_speed_multiplier
	character.velocity.x = direction * block_speed
	
	if direction != 0:
		character.animated_sprite.flip_h = direction < 0
	
	character.move_and_slide()
	return null # stay in the block state
