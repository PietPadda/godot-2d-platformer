# game_events.gd

extends Node

# global signals (library store, not actually used!)
@warning_ignore("unused_signal") # ignore next warning
signal coin_collected(value) # signal carries value forward
@warning_ignore("unused_signal") # ignore next warning
signal player_died
@warning_ignore("unused_signal") # ignore next warning
signal level_finished

# global variables
var current_score = 0 # init 0
