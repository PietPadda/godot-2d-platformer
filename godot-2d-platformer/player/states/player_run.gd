# player/states/player_run.gd
extends State # class type

# enter run state
func enter():
	character.animated_sprite.play("run")

func process_physics(delta) -> State:
	if not character.is_on_floor():
		return get_parent().get_node("Fall")
	if Input.is_action_just_pressed("ui_accept"):
		return get_parent().get_node("Jump")
	if Input.get_axis("ui_left", "ui_right") == 0:
		return get_parent().get_node("Idle")

	# Horizontal movement logic
	var direction = Input.get_axis("ui_left", "ui_right")
	
	var current_speed = character.stats.speed
	if character.is_blocking:
		current_speed = character.stats.speed * character.stats.block_speed_multiplier
		
	character.velocity.x = direction * current_speed * character.speed_modifier
	character.animated_sprite.flip_h = direction < 0
	
	if direction != 0:
		character.animated_sprite.flip_h = direction < 0

	character.move_and_slide()
	return null
