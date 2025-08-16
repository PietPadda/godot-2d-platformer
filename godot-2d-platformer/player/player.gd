# player/player.gd

# expose vars & funcs
extends CharacterBody2D

# ready nodes
@onready var sfx_player = $SFXPlayer
@onready var shield = $Shield

# constants
const SPEED = 500.0 # float
const JUMP_VELOCITY = -500.0 # float

# get global grav for rigidbody
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# variables
var jumps_left = 0 # init no jumps
var is_blocking = false # init non-blocking mode

# paths
const JUMP_SOUND = preload("res://assets/audio/player/jump.wav")

# movement physics
func _physics_process(delta):
	# VERTICAL MOVEMENT
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
		sfx_player.stream = JUMP_SOUND # set sfx
		sfx_player.play() # play sound once
		
	# variable jump height
	# hold jump button to go max, release to cut momentum
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY * 0 # stop all momentum
	
	# HORISONTAL MOVEMENT AND BLOCKING
	# block on input
	is_blocking = Input.is_action_pressed("block") # true if input
	shield.visible = is_blocking # visible if block held
	
	# capture horisontal speed
	var current_speed = SPEED
	if is_blocking:
		current_speed = SPEED * 0.4 # reduced speed when blocking
	
	# get left/right input
	# Input.get_axis() returns a value between -1 and 1.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# left/right movement
	if direction != 0: # if dir applied
		velocity.x = direction * current_speed # add hor speed
	else: # no left/right input
		velocity.x = 0 # stop if no left/right
		
	# ANIMATION & VISUALS
	if direction != 0: # if dir applied
		$AnimatedSprite2D.flip_h = direction < 0 # flip if going left
	
	# set player animation state
	# jump/fall
	if not is_on_floor(): # if in air
		$AnimatedSprite2D.play("jump")
	elif direction != 0: # if running
		$AnimatedSprite2D.play("run")
	# TODO: Add blocking animation
	else: # default
		$AnimatedSprite2D.play("idle") # idle anim
		
	# SHIELD SYNC
	# ensure shield positioned and flipped correctly
	var shield_sprite = $Shield.get_node("Sprite2D")

	# match shield to player sprite flip
	shield_sprite.flip_h = $AnimatedSprite2D.flip_h

	# update shield position to be front of  player
	# get base distance of shield from player.
	var shield_offset_x = abs(shield.position.x)
	
	# if player flipped left, move the shield to  left
	if $AnimatedSprite2D.flip_h:
		shield.position.x = -shield_offset_x
	else: # else to right
		shield.position.x = shield_offset_x
		
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

# projectile enter shield hitbox
func _on_shield_area_entered(area: Area2D) -> void:
	area.queue_free() # destroys the "area" that entered the hitbox
