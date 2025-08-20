# enemies/side_detector.gd

extends Area2D

# ready nodes
@onready var damage_timer = $DamageTimer

# script scope vars
var player_body = null # init player reference
var parent_body = null # init parent reference

# initialisation at scene start
func _ready():
	# get ref to parent node (BaseEnemy) when scene starts
	parent_body = get_parent() # parent refer

# player enter side detector
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not parent_body.is_stomped:
		player_body = body # player reference
		GameEvents.deal_damage_to_player.emit(1) # deal damage
		damage_timer.start() # start dmg timer

# player exit side detector
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		damage_timer.stop() # stop dmg timer

# damage timer tick
func _on_damage_timer_timeout() -> void:
	if is_instance_valid(player_body) and not parent_body.is_stomped:
		GameEvents.deal_damage_to_player.emit(1) # deal damage per tick
