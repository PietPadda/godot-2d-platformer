# collectibles/speed_boost.gd

extends Area2D

# player enter speedboost
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): # if body is player
		GameEvents.speed_boost_collected.emit() # send boost signal
		queue_free() # delete the speed boost
