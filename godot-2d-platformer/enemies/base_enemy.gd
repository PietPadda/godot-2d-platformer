# enemies/base_enemy.gd

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
			# if have WalkComponent, tell it to patrol
			if has_node("WalkComponent"):
				$WalkComponent.patrol(delta)
		CHASE:
			# if have a WalkComponent, tell it to chase
			if has_node("WalkComponent"):
				$WalkComponent.chase(delta, player)
			# if have a ShootComponent, tell it to consider shooting
			if has_node("ShootComponent"):
				$ShootComponent.process_shooting()

# player touches enemy anywhere else
func _on_side_detector_body_entered(body: Node2D) -> void:
		# player touch collision box and stomp state false
	if body.is_in_group("player") and not is_stomped:
		# player hit from the side
		# emit signal for player damage
		GameEvents.deal_damage_to_player.emit(1)

# player lands on enemy head
func _on_stomp_detector_body_entered(body: Node2D) -> void:
	# player touch collision box and stomp state false
	if body.is_in_group("player") and not is_stomped:
		die() # call death on hit
		
		# add a small bounce for the player
		body.velocity.y = body.JUMP_VELOCITY * 0.7 

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
			shoot_timer.start(2)

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
	die() # call death on hit

# mob death handling
func die():
	# edge case: can't die twice
	if is_stomped:
		return # early exit
	
	is_stomped = true # set to stomped state
		
	# when stomped, the mobMob stops moving and gets squashed
	set_physics_process(false) # completely stop the physics process
	animated_sprite.play("squashed") # play death animation
	sfx_player.stream = SQUASH_SOUND # set SFX
	sfx_player.play() # play SFX
	shoot_timer.stop() # stop bullet firing
	
	# disable detectors and collision box
	$CollisionShape2D.set_deferred("disabled", true) # main solid body
	$SideDetector.monitoring = false
	$StompDetector.monitoring = false

	# start timer to deletion
	$DeathTimer.start()
