# enemies/stats/enemy_stats.gd

extends Resource # base class

class_name EnemyStats # global name

# ENEMY
# stats
@export var max_health: int = 1
# speed
@export var speed: float = 100.0
@export var chase_speed_multiplier: float = 1.0
@export var bounce_factor: float = 1.0
# damage
@export var contact_damage: int = 1

# SHOOTING
# flags
@export var can_shoot: bool = false
# scenes
@export var projectile_scene: PackedScene # drag into inspector
# speed
@export var fire_rate: float = 1.0
@export var projectile_speed: float = 100.0
# damage
@export var projectile_damage: int = 1
