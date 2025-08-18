# ui/ui.gd

extends CanvasLayer

# ready nodes
@onready var animation_player = $AnimationPlayer
@onready var score_label = $Label
@onready var sfx_player = $SFXPlayer
@onready var health_bar = $Control/HealthBar

# variables
var hearts = [] # init empty hearts array

# paths
const COIN_SOUND = preload("res://assets/audio/sounds/coin.wav")

# called on node entering scene
func _ready():
	# make UI listen for coin_collected global signal
	GameEvents.coin_collected.connect(on_coin_collected)
	update_score_label() # update score ui
	# make UI listen for player_died global signal
	GameEvents.player_died.connect(on_player_died)
	# make UI listen for animation_finished local signal
	animation_player.animation_finished.connect(on_animation_finished)
	# loop through all  children of HealthBar (our TextureRects)
	for heart in health_bar.get_children(): # get each child (heart)
		hearts.append(heart) # add each child to array
	
	# wait for game ready to update (prevent race conditions)
	GameEvents.game_ready.connect(on_game_ready) # all ready and init
	GameEvents.health_changed.connect(update_health_bar) # still update health

# runs ONLY when the 'game_ready' signal is emitted
func on_game_ready():
	update_score_label() # update score
	update_health_bar(GameEvents.current_health) # update health bar

# runs when coin emits signal
func on_coin_collected(value): # pass global score
	GameEvents.current_score += value # incr global score
	update_score_label() # update score ui
	
	# call the SFXPlayer to load COIN_SOUND
	sfx_player.stream = COIN_SOUND
	sfx_player.play() # play it once

# update score ui
func update_score_label():
	# prefix + score
	score_label.text = "Coins: " + str(GameEvents.current_score)

# called by the GameEvents signal
func on_player_died():
	animation_player.play("fade_to_black")

# called by the AnimationPlayer's signal
func on_animation_finished(anim_name):
	# check if fade_to_black animation finished
	if anim_name == "fade_to_black":
		# now reload the scene, after screen is black
		get_tree().reload_current_scene()

# health changeed
func update_health_bar(new_health):
	# loop through array of hearts
	for i in range(hearts.size()):
		# show heart if index LESS than new health
		if i < new_health:
			hearts[i].visible = true # checks to show
		# otherwise hide it
		else:
			hearts[i].visible = false # take damage
