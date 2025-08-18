# game_events.gd

extends Node

# global signals (library store, not actually used!)
@warning_ignore("unused_signal") # ignore next warning
signal coin_collected(value) # signal carries value forward
@warning_ignore("unused_signal") # ignore next warning
signal player_died
@warning_ignore("unused_signal") # ignore next warning
signal level_finished
@warning_ignore("unused_signal") # ignore next warning
signal health_changed(new_health)
@warning_ignore("unused_signal") # ignore next warning
signal deal_damage_to_player(amount)

# global variables
var current_score = 0 # init 0
var current_health = MAX_HEALTH # player hp tracker

# global constants
	# PLAYER
const MAX_HEALTH = 6 # init player hp
