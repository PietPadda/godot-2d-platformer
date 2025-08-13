extends Area2D

# run when body touches spikes
func _on_body_entered(body: Node2D) -> void:
	# player check
	if body.name == "Player": # node name, groups are better
		GameEvents.player_died.emit() # emit global signal
