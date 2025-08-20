# enemies/base_enemy.gd

extends CharacterBody2D

# resource file
@export var stats: EnemyStats

# state machine enums
enum {PATROL, CHASE} # efine our states
var state = PATROL # start in PATROL
var player = null # var to hold reference to  player

# ready nodes for use
@onready var animated_sprite = $AnimatedSprite2D
@onready var ground_check_ray = $RayCast2D
@onready var sfx_player = $SFXPlayer

# variables
# var speed = 40.0 # walk speed (NOW IN ENEMY_STATS.GD)
var direction: float # only init var
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_stomped = false # death state init
var active_projectile = null # project live init

# file paths
const SQUASH_SOUND = preload("res://assets/audio/enemy/bones_falling.wav")

# funct runs once when the mob is created
func _ready():
	# err check stats
	if not stats:
		printerr("Enemy stats resource not assigned to: ", name) # err log
		queue_free() # delete instance
		return # early exit
	
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
			# if have  Fly/WalkComponent, tell it to patrol
			if has_node("WalkComponent"):
				$WalkComponent.patrol(delta)
			elif has_node("FlyComponent"):
				$FlyComponent.chase(delta, player)
		CHASE:
			# if have a Fly/WalkComponent, tell it to chase
			if has_node("WalkComponent"):
				$WalkComponent.chase(delta, player)
			elif has_node("FlyComponent"):
				$FlyComponent.chase(delta, player)
			
			# if have a ShootComponent, tell it to consider shooting
			if has_node("ShootComponent"):
				$ShootComponent.process_shooting()

# player lands on enemy head
func _on_stomp_detector_body_entered(body: Node2D) -> void:
	# player touch collision box and stomp state false
	if body.is_in_group("player") and not is_stomped:
		die() # call death on hit
		
		# add a small bounce for the player
		body.velocity.y = body.JUMP_VELOCITY * stats.player_bounce_factor

# func called on timer one shot
func _on_timer_timeout() -> void:
	queue_free() # safely delete the mob from game

# func called on player entering the visibility radius
func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		state = CHASE # set mob to hunt the player
		player = body # the body it chases is the player
		
		# tell component player was spotted
		if has_node("ShootComponent"):
			$ShootComponent.on_player_detected()

# func called on player exiting the visibility radius
func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		state = PATROL # set mob to stop hunting
		player = null # "forget" about the player as it left vis circle

# public function the player can call
func hit():
	die() # call death on hit

# mob death handling
func die():
	# edge case: can't die twice
	if is_stomped:
		return # early exit
	is_stomped = true # set to stomped state
	
	# tell components to stop their actions
	if has_node("ShootComponent"):
		$ShootComponent.stop_shooting()
		
	# clean up our active projectile if one exists
	if is_instance_valid(active_projectile):
		active_projectile.queue_free()
		
	# when stomped, the mobMob stops moving and gets squashed
	set_physics_process(false) # completely stop the physics process
	animated_sprite.play("squashed") # play death animation
	sfx_player.stream = SQUASH_SOUND # set SFX
	sfx_player.play() # play SFX
	
	# disable detectors and collision box
	$CollisionShape2D.set_deferred("disabled", true) # main solid body
	$SideDetector.monitoring = false
	$StompDetector.monitoring = false

	# start timer to deletion
	$DeathTimer.start()
