# collectibles/health_pickup.gd

extends Area2D

# health picked up
func _on_body_entered(body: Node2D) -> void:
	# if a player and health isn't full
	if body.is_in_group("player") and (GameEvents.current_health < GameEvents.MAX_HEALTH):
		GameEvents.player_healed.emit(1) # heal signal
		queue_free() # remove pickup
