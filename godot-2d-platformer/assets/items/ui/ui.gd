extends CanvasLayer

var score = 0 # init
# @onready "readies" node before use
@onready var score_label = $Label

# called on node entering scene
func _ready():
	# link on_coin__collected func to global signal
	GameEvents.coin_collected.connect(on_coin_collected)

# runs when coin emits signal
func on_coin_collected():
	score += 1 # incr
	# prefix + score
	score_label.text = "Coins: " + str(score)
