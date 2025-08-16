# projectiles/pellet.gd

extends Area2D

# variables
var direction = Vector2.RIGHT
var speed = 250.0

# pellet physics
func _physics_process(delta):
	# move pellet every frame
	position += direction * speed * delta

# collission detection
func _on_body_entered(body):
	# hit the player, tell game they died
	if body.is_in_group("player"):
		GameEvents.player_died.emit()

	# destroy player on ANY collision
	queue_free()
