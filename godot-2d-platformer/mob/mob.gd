extends CharacterBody2D

# ready nodes for use
@onready var animated_sprite = $AnimatedSprite2D
@onready var ground_check_ray = $RayCast2D

# variables
var speed = 50.0 # walk speed
var direction = -1.0 # -1 for left, 1 for right
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# mob movement
func _physics_process(delta):
	# apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta # incr with -y acceleration

	# if ray not colliding with anything, means it's at an edge
	if not ground_check_ray.is_colliding():
		direction *= -1.0 # flip the direction
		scale.x *= -1.0 # flip the entire node (sprite and raycast)

	# general velocity
	velocity.x = direction * speed
	animated_sprite.play("walk") # walk animation
	
	# godots magic func for sliding on floor
	move_and_slide()

# player lands on enemy head
func _on_side_detector_body_entered(body: Node2D) -> void:
	# player touch collision box
	if body.is_in_group("player"):
		# When stomped, the Mob stops moving and gets squashed.
		speed = 0 # stop moving
		animated_sprite.play("squashed") # play death animation
		# add a small bounce for the player
		body.velocity.y = body.JUMP_VELOCITY * 0.7 

# player touches enemy anywhere else
func _on_stomp_detector_body_entered(body: Node2D) -> void:
	# player touch collision box
	if body.is_in_group("player"):
		# player hit from the side
		# emit signal for player death
		GameEvents.player_died.emit()
