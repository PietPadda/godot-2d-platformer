extends Area2D

# runs when a physics body enters area
func _on_body_entered(body: Node2D) -> void:
	# check if player entered body
	if body.name == "Player":
		# remove node at end of phys frame
		queue_free()
