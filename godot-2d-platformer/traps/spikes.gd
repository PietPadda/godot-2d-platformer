extends Area2D

# run when body touches spikes
func _on_body_entered(body: Node2D) -> void:
	# check if player entered body
	if body.is_in_group("player"):
		GameEvents.deal_damage_to_player.emit(1) # emit global signal
