# player/player.gd

extends CharacterBody2D # scene class

# resource file
@export var stats: PlayerStats

# ready nodes
@onready var sfx_player = $SFXPlayer
@onready var shield = $Shield
@onready var slash_effect = $SlashEffect
@onready var dash_tap_timer = $DashTapTimer
@onready var dash_duration_timer = $DashDurationTimer
@onready var powerup_timer = $PowerupTimer
@onready var invincibility_timer = $InvincibilityTimer

# get global grav for rigidbody
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# variables
var jumps_left = 0 # init no jumps
var is_blocking = false # init non-blocking mode
var is_slashing = false # init non-slashing mode
var direction: float # init direction var
var current_speed: float # declare curr speed type
var dash_tap_count = 0 # count dash input attemps
var last_dash_direction = 0 # track dash direction if double
var is_dashing = false # init dash mode
var speed_modifier = 1.0 # 100% speed, our default
var is_invincible = false # invicibility frames after taking dmg

# paths
const JUMP_SOUND = preload("res://assets/audio/player/jump.wav")
const SLASH_SOUND = preload("res://assets/audio/player/sword_slash.wav")
const DASH_SOUND = preload("res://assets/audio/player/double_dash.wav")
const HURT_SOUND = preload("res://assets/audio/player/hurt.wav")
const SPEED_POWERUP_SOUND = preload("res://assets/audio/player/speed_powerup.wav")
const HEAL_SOUND = preload("res://assets/audio/player/heal.wav")

# called on node entering scene
func _ready():
	# err check stats
	if not stats:
		printerr("Player stats resource not assigned to: ", name) # err log
		queue_free() # delete instance
		return # early exit
		
	# player tells global state what consts are via stats file
	GameEvents.MAX_HEALTH = stats.max_health
	GameEvents.current_health = stats.max_health
	GameEvents.health_changed.emit(GameEvents.current_health)
		
	# link LOCAL func to GLOBAL SIGNAL
	GameEvents.player_died.connect(on_player_died)
	GameEvents.deal_damage_to_player.connect(take_damage)
	GameEvents.speed_boost_collected.connect(on_speed_boost_collected)
	GameEvents.player_healed.connect(on_player_healed)

# physics handling
func _physics_process(delta):
	# delegate all state-based logic to the state machine
	$StateMachine._physics_process(delta)
	
	# visuals that need to sync every frame, regardless of state
	sync_visuals()

# helper function to manage visuals
func sync_visuals():
	# same logic from the end of our old _physics_process
	var shield_sprite = $Shield.get_node("Sprite2D") # Note: using @onready is safer

	shield_sprite.flip_h = $AnimatedSprite2D.flip_h
	slash_effect.flip_h = $AnimatedSprite2D.flip_h
	
	var shield_offset_x = abs(shield.position.x)
	var slash_offset_x = abs(slash_effect.position.x)
	
	if $AnimatedSprite2D.flip_h:
		shield.position.x = -shield_offset_x
		slash_effect.position.x = -slash_offset_x
	else:
		shield.position.x = shield_offset_x
		slash_effect.position.x = slash_offset_x

# non-physics handling
func _unhandled_input(event):
	# check for the right tap
	if event.is_action_pressed("ui_right"):
		# both were right and twice
		if last_dash_direction == 1 and dash_tap_count == 1: 
			# successful double-tap right
			print("Dashing right!") # DEBUG
			dash(1) # call single dash
		else: # first attempt
			last_dash_direction = 1 # incr
			dash_tap_count = 1 # incr
			dash_tap_timer.start() # timer till reset attempt

	# check for the left tap
	if event.is_action_pressed("ui_left"):
		# both were left and twice
		if last_dash_direction == -1 and dash_tap_count == 1:
			# successful double-tap left
			print("Dashing left!") # DEBUG
			dash(-1) # call single dash
		else: # first attempt
			last_dash_direction = -1 # incr
			dash_tap_count = 1 # incr
			dash_tap_timer.start() # timer till reset attempt

# player take damage
func take_damage(amount):
	# invincibility frame check
	if is_invincible:
		return # early return
	# reduce global health
	GameEvents.current_health -= amount
	# announce the health has changed
	GameEvents.health_changed.emit(GameEvents.current_health)
	
	# check if player has run out of health
	if GameEvents.current_health <= 0: # no health
		# 0 hp
		GameEvents.player_died.emit() # player DIED
	else: # take danage
		is_invincible = true # set invin frames
		invincibility_timer.start() # start invin frames timer
		sfx_player.stream = HURT_SOUND # set sfx
		sfx_player.play() # play sound once
		# TODO: make the player flash for a moment

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
		body.hit() # call the "enemy hit" logic

# double dash func
func dash(direction_of_dash):
	# edge case: no dash while busy with another action
	if is_blocking or is_slashing or is_dashing:
		return # early return
		
	is_dashing = true # we're dashing!
	velocity.y = 0 # we stop verticality and "jump" to side
	velocity.x = direction_of_dash * stats.speed * stats.dash_speed_multiplier # jump in dash dir
	dash_duration_timer.start() # dash starts!
	sfx_player.stream = DASH_SOUND # set sfx
	sfx_player.play() # play sound once

# reset double dash on timer
func _on_dash_tap_timer_timeout() -> void:
	# reset the tap attempt
	dash_tap_count = 0
	last_dash_direction = 0

# finished dashing after timer
func _on_dash_duration_timer_timeout() -> void:
	is_dashing = false # dash is done
	velocity.x = 0 # suddent stop!
	
# speedboost powerup
func on_speed_boost_collected() -> void:
	speed_modifier = stats.speed_powerup
	powerup_timer.start() # start timer
	sfx_player.stream = SPEED_POWERUP_SOUND # set sfx
	sfx_player.play() # play sound once
	# TODO: add a visual effect!

# powerup expired
func _on_powerup_timer_timeout() -> void:
	speed_modifier = 1.0 # reset to normal

# health pickup
func on_player_healed(amount):
	# heal but no more than max hp
	if GameEvents.current_health >= GameEvents.MAX_HEALTH:
		return # early exit, already full
	else: # otherwise heal
		GameEvents.current_health = min(GameEvents.current_health + amount, GameEvents.MAX_HEALTH) # update health
		GameEvents.health_changed.emit(GameEvents.current_health)
		sfx_player.stream = HEAL_SOUND # set sfx
		sfx_player.play() # play sound once

# invin frames expire
func _on_invincibility_timer_timeout() -> void:
	is_invincible = false # vulnerable
	# TODO: Stop the visual flashing effect here.
