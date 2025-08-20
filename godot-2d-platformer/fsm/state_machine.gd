# fsm/state_machine.gd
extends Node # class type

# ready nodes
@export var initial_state: NodePath

# script vars
var current_state: State

# init func
func _ready():
	# give each state ref to the char (parent of node)
	for child in get_children(): # loop thru direct child nodes of state machine
		if child is State:# check if child node is a state type
			child.character = get_parent() # give state ref to it's char (parent of node)

	# start with initial state
	current_state = get_node(initial_state) # based on exported path
	current_state.enter() # activate initial state

func _physics_process(delta):
	if current_state: # only process if active state exists
		# run the logic for the active state
		var next_state = current_state.process_physics(delta)
		# if the state wants to transition, change to  new state
		if next_state:
			transition_to(next_state) # move to the suggested new state

func transition_to(new_state: State):
	# if new state already current state, do nothing
	if current_state == new_state:
		return # exit transition_to

	# if a current state, exit it
	if current_state:
		current_state.exit()
	
	current_state = new_state # update current state to new
	current_state.enter() # activate new state
