# player/player.gd

extends CharacterBody2D # scene class

# ready nodes
@onready var sfx_player = $SFXPlayer
@onready var shield = $Shield
@onready var slash_effect = $SlashEffect

# constants
const SPEED = 500.0 # float
const JUMP_VELOCITY = -500.0 # float

# get global grav for rigidbody
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# variables
var jumps_left = 0 # init no jumps
var is_blocking = false # init non-blocking mode
var is_slashing = false # init non-slashing mode
var direction: float # init direction var
var current_speed = SPEED # capture horisontal speed

# paths
const JUMP_SOUND = preload("res://assets/audio/player/jump.wav")
const SLASH_SOUND = preload("res://assets/audio/player/sword_slash.wav")

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
		
	# ATTACK
	# attack on button and animation has reset
	if Input.is_action_just_pressed("attack") and not is_slashing:
		is_slashing = true # set slash mode
		slash_effect.visible = is_slashing # visible if slash pressed
		slash_effect.play("default") # play animation AT attack
		$SlashEffect/Hitbox/CollisionShape2D.disabled = false # false disable = enable hitbox!
		sfx_player.stream = SLASH_SOUND # set sfx
		sfx_player.play() # play sound once
	
	# HORISONTAL MOVEMENT AND BLOCKING
	# block on input
	is_blocking = Input.is_action_pressed("block") and not is_slashing # true if input
	shield.visible = is_blocking # visible if block held
	$Shield/CollisionShape2D.disabled = not is_blocking # only hitbox when visible
	
	# player movement state
	if is_slashing:
		# stop in tracks
		velocity.x = 0
	else: # not attacking
		current_speed = SPEED # default movement speed
		# modify speed if blocking
		if is_blocking:
			current_speed = SPEED * 0.4 # reduced speed when blocking
			
		# get left/right input
		# Input.get_axis() returns a value between -1 and 1.
		direction = Input.get_axis("ui_left", "ui_right")
		
		# left/right movement
		if direction != 0: # if dir applied
			velocity.x = direction * current_speed # add hor speed
		else: # no left/right input
			velocity.x = 0 # stop if no left/right
		
	# ANIMATION & VISUALS
	if direction != 0: # if dir applied
		$AnimatedSprite2D.flip_h = direction < 0 # flip if going left
	
	# set player animation state
	# jump/fall animation
	if not is_on_floor(): # if in air
		$AnimatedSprite2D.play("jump")
	# running animation
	elif direction != 0:
		$AnimatedSprite2D.play("run")
	# default animation
	else:
		$AnimatedSprite2D.play("idle") # idle anim
		
	# SHIELD & ATTACK SYNC
	# ensure shield positioned and flipped correctly
	var shield_sprite = $Shield.get_node("Sprite2D")

	# match animations to player sprite flip
	shield_sprite.flip_h = $AnimatedSprite2D.flip_h
	slash_effect.flip_h = $AnimatedSprite2D.flip_h

	# update shield position to be front of  player
	# get base distance of shield/slash from player.
	var shield_offset_x = abs(shield.position.x)
	var slash_offset_x = abs(slash_effect.position.x)
	
	# if player flipped left, flip the shield/slash to left
	if $AnimatedSprite2D.flip_h:
		shield.position.x = -shield_offset_x
		slash_effect.position.x = -slash_offset_x
	else: # else to right
		shield.position.x = shield_offset_x
		slash_effect.position.x = slash_offset_x
		
	# func that moves the char
	move_and_slide()

# called on node entering scene
func _ready():
	# link on_player_died func to global signal
	GameEvents.player_died.connect(on_player_died)

# player death animation
func on_player_died():
	set_physics_process(false) # stop processing physics
	$AnimatedSprite2D.hide() # hide the player

# projectile enter shield hitbox
func _on_shield_area_entered(area: Area2D) -> void:
	area.queue_free() # destroys the "area" that entered the hitbox

# slash finished
func _on_slash_effect_animation_finished() -> void:
	is_slashing = false # return control to player
	slash_effect.visible = false # hide again
	$SlashEffect/Hitbox/CollisionShape2D.disabled = true # disable hitbox!

# slash hit enemy
func _on_hitbox_body_entered(body: Node2D) -> void:
	# check if enemies group entered slash hitbix AND if has hit function
	if body.is_in_group("enemies") and body.has_method("hit"):
		body.slash_hit()
