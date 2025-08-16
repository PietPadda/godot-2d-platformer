# player/player.gd

# expose vars & funcs
extends CharacterBody2D

# constants
const SPEED = 400.0 # float
const JUMP_VELOCITY = -450.0 # float

# get global grav for rigidbody
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# variables
var jumps_left = 0 # init no jumps

# movement physics
func _physics_process(delta):
	# add gravity 
	if not is_on_floor(): # apply when not on floor
		velocity.y += gravity * delta # increase grav vector
	
	# reset jumps if on floor
	if is_on_floor():
		jumps_left = 2 # double jump
		
	# jump on accept button + have jumps left
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY # sudden jump velocity
		jumps_left -= 1 # decr jumps
		
	# variable jump height
	# hold jump button to go max, release to cut momentum
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY * 0 # stop all momentum
		
	# get left/right input
	# Input.get_axis() returns a value between -1 and 1.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# left/right movement
	if direction != 0: # if dir applied
		velocity.x = direction * SPEED # add hor speed
		$AnimatedSprite2D.flip_h = direction < 0 # flip if going left
		$AnimatedSprite2D.play("run") # animation if going right
	else: # no left/right input
		velocity.x = 0 # stop if no left/right
		$AnimatedSprite2D.play("idle") # idle anim
		
	# jump/fall
	if not is_on_floor(): # if in air
		$AnimatedSprite2D.play("jump")
		
	# func that moves the char
	move_and_slide()

# called on node entering scene
func _ready():
	# link on_player_died func to global signal
	GameEvents.player_died.connect(on_player_died)

# player death animation
func on_player_died():
	set_physics_process(false) # stop processing physics
	$AnimatedSprite2D.hide() #  hide the player.
