# enemies/enemy_stats.gd

extends Resource # base class

class_name EnemyStats # global name

# enemy stats
@export var max_health: int = 1
@export var speed: float = 40.0
@export var chase_speed_multiplier: float = 1.5
@export var player_bounce_factor: float = 0.7

# shooting stats
@export var can_shoot: bool = true
@export var fire_rate: float = 2.0
@export var projectile_scene: PackedScene
