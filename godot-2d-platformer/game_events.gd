# game_events.gd

extends Node

# global signals (library store, not actually used!)
@warning_ignore("unused_signal")  # ignore next warning
signal game_ready

@warning_ignore("unused_signal")
signal deal_damage_to_player(amount)
@warning_ignore("unused_signal")
signal health_changed(new_health)

@warning_ignore("unused_signal")
signal player_died
@warning_ignore("unused_signal")
signal level_finished

@warning_ignore("unused_signal")
signal coin_collected(value) # signal carries value forward
@warning_ignore("unused_signal")
signal speed_boost_collected

# global variables
var current_score = 0 # init 0
var current_health = MAX_HEALTH # player hp tracker

# global constants
	# PLAYER
const MAX_HEALTH = 6 # init player hp
