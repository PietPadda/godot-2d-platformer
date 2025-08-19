# enemies/components/walk_component.gd

extends Node

# script scope vars
var body: CharacterBody2D

# ready scene nodes
@onready var animated_sprite = get_parent().get_node("AnimatedSprite2D")
@onready var ground_check_ray = get_parent().get_node("RayCast2D")
@onready var muzzle = get_parent().get_node("Muzzle")

func _ready():
	# get reference to enemy body this component is attached to
	body = get_parent()

func patrol(delta):
	if not body.is_on_floor(): 
		body.velocity.y += body.gravity * delta # apply grav
	if not ground_check_ray.is_colliding():
		body.direction *= -1.0 # turn around if at edge
	body.velocity.x = body.direction * body.speed # walk
	update_visuals() # update animations
	body.move_and_slide() # move

func chase(delta, player_ref):
	if not body.is_on_floor():
		body.velocity.y += body.gravity * delta # apply grav
	# func var
	var direction_to_player = (player_ref.global_position - body.global_position).normalized()
	if direction_to_player.x > 0: 
		body.direction = 1.0  # move right
	else: 
		body.direction = -1.0 # move left
	body.velocity.x = body.direction * body.speed * 1.5 # hor vel
	update_visuals() # update animations
	body.move_and_slide() # move

func update_visuals():
	animated_sprite.flip_h = body.direction < 0 # flip if true
	if body.direction > 0:
		ground_check_ray.target_position.x = abs(ground_check_ray.target_position.x) # right
		muzzle.position.x = abs(muzzle.position.x) # right
	else:
		ground_check_ray.target_position.x = -abs(ground_check_ray.target_position.x) # left
		muzzle.position.x = -abs(muzzle.position.x) # left
	animated_sprite.play("walk") # walk animation
