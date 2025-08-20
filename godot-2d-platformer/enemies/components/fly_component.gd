# enemies/components/fly_component.gd

extends Node

# script scope vars
var body: CharacterBody2D

# ready nodes
@onready var animated_sprite = get_parent().get_node("AnimatedSprite2D")

func _ready():
	# get reference to  enemy body  component attached to
	body = get_parent()
	# flying enemies ignore gravity
	body.gravity = 0 # override

func patrol(_delta): # unused delta for now
	# when patrolling, bat will just hover in place
	body.velocity = body.velocity.lerp(Vector2.ZERO, 0.05) # hover
	animated_sprite.play("sleep") # animation
	body.move_and_slide() # move

func chase(delta, player_ref):
	if not is_instance_valid(player_ref):
		# edge case: player gone, just hover
		patrol(delta)
		return # early exit

	# fly directly towards the player (chase scope var)
	var direction_to_player = (player_ref.global_position - body.global_position).normalized()
	# use body's speed variable from base script
	body.velocity = direction_to_player * body.speed

	animated_sprite.flip_h = body.velocity.x < 0 # flip if going left
	animated_sprite.play("fly")
	body.move_and_slide()
