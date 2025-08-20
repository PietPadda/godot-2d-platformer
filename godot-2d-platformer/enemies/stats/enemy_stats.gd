# enemies/stats/enemy_stats.gd

extends Resource # base class

class_name EnemyStats # global name

# enemy stats
@export var max_health: int = 1
@export var speed: float = 50.0
@export var chase_speed_multiplier: float = 1.0
@export var bounce_factor: float = 0.5

# shooting stats
@export var can_shoot: bool = true
@export var fire_rate: float = 1.0
@export var projectile_scene: PackedScene # drag into inspector
