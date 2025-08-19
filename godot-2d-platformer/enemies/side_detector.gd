# enemies/side_detector.gd

extends Area2D

# ready nodes
@onready var damage_timer = $DamageTimer

# player enter side detector
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameEvents.deal_damage_to_player.emit(1) # deal damage
		damage_timer.start() # start dmg timer

# player exit side detector
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		damage_timer.start() # start dmg timer

# damage timer tick
func _on_damage_timer_timeout() -> void:
	GameEvents.deal_damage_to_player.emit(1) # deal damage per tick
