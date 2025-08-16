# ui/coin.gd

extends Area2D

# runs when a physics body enters area
func _on_body_entered(body: Node2D) -> void:
	# check if player entered body
	if body.is_in_group("player"):
		# announce to game that coin collected (emit signal)
		GameEvents.coin_collected.emit(1) # add coin to global score
		queue_free() # remove node at end of phys frame
