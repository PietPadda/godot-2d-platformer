# mob/mob.gd

extends CharacterBody2D

# state machine enums
enum {PATROL, CHASE} # efine our states
var state = PATROL # start in PATROL
var player = null # var to hold reference to  player

# ready nodes for use
@onready var animated_sprite = $AnimatedSprite2D
@onready var ground_check_ray = $RayCast2D
@onready var sfx_player = $SFXPlayer
@onready var shoot_timer = $ShootTimer
@onready var muzzle = $Muzzle

# variables
var speed = 40.0 # walk speed
var direction: float # only init var
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_stomped = false # death state init
var active_projectile = null # project live init

# file paths
const SQUASH_SOUND = preload("res://assets/audio/enemy/bones_falling.wav")
const SHOOT_SOUND = preload("res://assets/audio/projectiles/pellet.wav")
const PELLET_SCENE = preload("res://projectiles/pellet.tscn")

# funct runs once when the mob is created
func _ready():
	# randi() % 2 gives us either 0 or 1, perfect 50/50 chance
	if randi() % 2 == 0: # if even
		direction = 1.0 # Go right
	else: # if odd
		direction = -1.0 # Go left

# this is our state machine manager
func _physics_process(delta):
	# stomped state
	if is_stomped:
		return # early exit

	# state machine
	match state:
		PATROL:
			patrol_state(delta)
		CHASE:
			chase_state(delta)

# mob movement (old _physics_process func)
func patrol_state(delta):
	# if mob  stomped, STOP patrol logic
	if is_stomped:
		return
	
	# apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta # incr with -y acceleration

	# if ray not colliding with anything, means it's at an edge
	if not ground_check_ray.is_colliding():
		direction *= -1.0 # flip the direction

	# general velocity
	velocity.x = direction * speed
	
	# muzzle update
	if direction > 0: # face right
		muzzle.position.x = abs(muzzle.position.x)
	else: # face left
		muzzle.position.x = -abs(muzzle.position.x)
		
	# flip_h true if -1 (left), false if 1 (right, default)
	animated_sprite.flip_h = direction < 0
	
	# stateless raycast flip
	# set ray's direction based on the 'direction' variable every frame
	if direction > 0: # moving right
		ground_check_ray.target_position.x = abs(ground_check_ray.target_position.x)
	else: # moving left
		ground_check_ray.target_position.x = -abs(ground_check_ray.target_position.x)
		
	animated_sprite.play("walk") # walk animation
	move_and_slide() # godots magic func for sliding on floor

# mob chase state
func chase_state(delta):
	# if mob  stomped, STOP chase logic
	if is_stomped:
		return
		
	# apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# edge case
	# if player disappears, go back to patrolling
	if not is_instance_valid(player):
		state = PATROL
		return
	
	# calc direction to player and move towards them
	# player - mob position to get either + or - value
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# update direction
	if direction_to_player.x > 0: # player to the right
		direction = 1 # right
	else:
		direction = -1 # left
		
	# apply velocity vector with chase speed boost
	velocity.x = direction_to_player.x * speed * 4 # chase a bit faster
	
	# muzzle update
	if direction > 0: # face right
		muzzle.position.x = abs(muzzle.position.x)
	else: # face left
		muzzle.position.x = -abs(muzzle.position.x)
	
	# standard sprite flip and walk logic
	animated_sprite.flip_h = velocity.x < 0
	animated_sprite.play("walk")
	move_and_slide()
	
	# shoot logic
	# if timer has finished and no active project
	if shoot_timer.is_stopped() and not is_instance_valid(active_projectile):
		shoot_timer.start() # restart the timer

# player lands on enemy head
func _on_side_detector_body_entered(body: Node2D) -> void:
		# player touch collision box and stomp state false
	if body.is_in_group("player") and not is_stomped:
		# player hit from the side
		# emit signal for player death
		GameEvents.player_died.emit()

# player touches enemy anywhere else
func _on_stomp_detector_body_entered(body: Node2D) -> void:
	# player touch collision box and stomp state false
	if body.is_in_group("player") and not is_stomped:
		is_stomped = true # set to stomped state
		
		# when stomped, the mobMob stops moving and gets squashed
		set_physics_process(false) # completely stop the physics process
		animated_sprite.play("squashed") # play death animation
		sfx_player.stream = SQUASH_SOUND # set SFX
		sfx_player.play() # play SFX
		shoot_timer.stop() # stop bullet firing
		
		# add a small bounce for the player
		body.velocity.y = body.JUMP_VELOCITY * 0.7 
		
		# disable detectors and collision box
		$CollisionShape2D.set_deferred("disabled", true) # main solid body
		$SideDetector.monitoring = false
		$StompDetector.monitoring = false

		# start timer to deletion
		$Timer.start()

# func called on timer one shot
func _on_timer_timeout() -> void:
	queue_free() # safely delete the mob from game

# func called on player entering the visibility radius
func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		state = CHASE # set mob to hunt the player
		player = body # the body it chases is the player
		
		# first pellet has reduced timer for responsiveness
		if shoot_timer.is_stopped() and not is_instance_valid(active_projectile):
			# override the timer on first detection with short time
			shoot_timer.start(0.5)

# func called on player exiting the visibility radius
func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		state = PATROL # set mob to stop hunting
		player = null # "forget" about the player as it left vis circle

# project shooting logic
func _on_shoot_timer_timeout() -> void:
	# edge case: ensure player exists
	if not is_instance_valid(player):
		return # early exit
	
	# pellet shoot
	sfx_player.stream = SHOOT_SOUND # set SFX
	sfx_player.play() # play SFX
		
	# create and store pellet instance
	var pellet = PELLET_SCENE.instantiate() # pellet instance create
	active_projectile = pellet # store instance
	
	get_parent().add_child(pellet) # add pellet to level scene
	# set starting position to Muzzle's global position
	pellet.global_position = muzzle.global_position
	# tell pellet which direction
	pellet.direction = Vector2(direction, 0) # use enemy's direction
	
# public function the player can call
func hit():
	# reuse the same logic as being stomped
	if not is_stomped:
		_on_stomp_detector_body_entered(self)
