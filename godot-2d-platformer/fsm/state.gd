# fsm/state.gd
extends Node # class type
class_name State # class name

# ready nodes
# animation helper
# @onready var animation_player: AnimationPlayer = character.get_node("AnimationPlayer")

# script vars
var character: CharacterBody2D # ref to char state belongs to (player or enemy)

# called when entering this state
func enter():
	pass

# called when exiting this state
func exit():
	pass

# runs every physics frame ONLY while we in this state
func process_physics(delta):
	pass
