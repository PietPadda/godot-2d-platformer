extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# disable collision shape on first touch to prevent signal loop
		$CollisionShape2D.set_deferred("disabled", true)
		GameEvents.level_finished.emit() # send out global signal
