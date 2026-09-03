extends Node
class_name HealthComponent

signal health_changed(current: float, maximum: float)
signal died(source: Node)

@export var max_health := 100.0
@export var invulnerability_seconds := 0.0

var health := 100.0
var _invulnerable_until := 0

func _ready() -> void:
    health = max_health

func apply_damage(amount: float, source: Node = null) -> bool:
    if amount <= 0.0 or health <= 0.0:
        return false
    var now := Time.get_ticks_msec()
    if now < _invulnerable_until:
        return false
    health = max(health - amount, 0.0)
    if invulnerability_seconds > 0.0:
        _invulnerable_until = now + int(invulnerability_seconds * 1000.0)
    health_changed.emit(health, max_health)
    if health <= 0.0:
        died.emit(source)
    return true

func heal(amount: float) -> void:
    if amount <= 0.0 or health <= 0.0:
        return
    health = min(health + amount, max_health)
    health_changed.emit(health, max_health)

func reset_health() -> void:
    health = max_health
    _invulnerable_until = 0
    health_changed.emit(health, max_health)

func is_dead() -> bool:
    return health <= 0.0
