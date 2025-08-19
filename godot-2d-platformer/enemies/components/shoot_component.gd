# enemies/components/shoot_component.gd

extends Node

# script scope vars
var body: CharacterBody2D

# ready nodes
@onready var shoot_timer = get_parent().get_node("ShootTimer")

func _ready():
	body = get_parent() # get ref to enemy body component attached to

func process_shooting():
	# if timer stopped and pellet exists
	if shoot_timer.is_stopped() and not is_instance_valid(body.active_projectile):
		shoot_timer.start() # restart timer
