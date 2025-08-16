# game_events.gd

extends Node

# global signals
signal coin_collected(value) # signal carries value forward
signal player_died
signal level_finished

# global variables
var current_score = 0 # init 0
