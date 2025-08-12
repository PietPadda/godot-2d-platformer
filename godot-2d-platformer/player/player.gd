# expose vars & funcs
extends CharacterBody2D

# constants
const SPEED = 300.0 # float
const JUMP_VELOCITY = -400.0 # float

# get global grav for rigidbody
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# movement physics
func _physics_process(delta):
	# add grav
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# get left/right input
	# Input.get_axis() returns a value between -1 and 1.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# left/right movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0 # stop if no left/right
		
	# func that moves the char
	move_and_slide()
		
	
	
