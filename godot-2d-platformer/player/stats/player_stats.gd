# player/stats/player_stats.gd

extends Resource # base class

class_name PlayerStats # class name

# player stats
@export var max_health: int = 6
@export var speed: float = 350.0
@export var jump_velocity: float = -500.0
@export var dash_speed_multiplier: float = 2.5
@export var block_speed_multiplier: float = 0.4
@export var speed_powerup: float = 1.6
