extends CanvasLayer

# ready the animation_player node
@onready var animation_player = $AnimationPlayer

var score = 0 # init
# @onready "readies" node before use
@onready var score_label = $Label

# ready the sfx_player node
@onready var sfx_player = $SFXPlayer

# paths to sound files
const COIN_SOUND = preload("res://assets/audio/sounds/coin.wav")

# called on node entering scene
func _ready():
	# make UI listen for coin_collected global signal
	GameEvents.coin_collected.connect(on_coin_collected)
	# make UI listen for player_died global signal
	GameEvents.player_died.connect(on_player_died)
	# make UI listen for animation_finished local signal
	animation_player.animation_finished.connect(on_animation_finished)

# runs when coin emits signal
func on_coin_collected():
	score += 1 # incr
	# prefix + score
	score_label.text = "Coins: " + str(score)
	
	# call the SFXPlayer to load COIN_SOUND
	sfx_player.stream = COIN_SOUND
	sfx_player.play() # play it once
	
# called by the GameEvents signal
func on_player_died():
	animation_player.play("fade_to_black")

# called by the AnimationPlayer's signal
func on_animation_finished(anim_name):
	# check if fade_to_black animation finished
	if anim_name == "fade_to_black":
		# now reload the scene, after screen is black
		get_tree().reload_current_scene()
