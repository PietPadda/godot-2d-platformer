# enemies/components/shoot_component.gd

extends Node

# script scope vars
var body: CharacterBody2D
var active_projectile = null # project live init
var direction: float # only init var

# ready nodes
@onready var shoot_timer = get_parent().get_node("ShootTimer")
@onready var muzzle = get_parent().get_node("Muzzle")
@onready var sfx_player = get_parent().get_node("SFXPlayer")

# paths
const SHOOT_SOUND = preload("res://assets/audio/projectiles/pellet.wav")
const PELLET_SCENE = preload("res://projectiles/pellet.tscn")

func _ready():
	body = get_parent() # get ref to enemy body component attached to
	
	# connect ShootTimer node to our func
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func on_player_detected():
	if shoot_timer.is_stopped() and not is_instance_valid(active_projectile):
		shoot_timer.start(0.5) # start earlier
		
func process_shooting():
	# if timer stopped and pellet exists
	if shoot_timer.is_stopped() and not is_instance_valid(active_projectile):
		shoot_timer.start() # restart timer

func stop_shooting():
	shoot_timer.stop()

# project shooting logic
func _on_shoot_timer_timeout() -> void:
	# edge case: ensure player exists
	if not is_instance_valid(body.player):
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
	pellet.direction = Vector2(body.direction, 0) # use enemy's direction via body
	
	# set pellet speed from enemy stats
	if body.stats:
		pellet.speed = body.stats.projectile_speed
	
