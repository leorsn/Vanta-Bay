extends CharacterBody3D
class_name VantaHostileAgent

signal defeated(agent: Node)

const HealthComponentScript = preload("res://scripts/health_component.gd")

@export var move_speed := 4.6
@export var strafe_speed := 3.6
@export var engagement_range := 24.0
@export var preferred_range := 13.0
@export var fire_damage := 7.0
@export var fire_interval := 1.0
@export var max_health := 85.0
@export var flank_distance := 8.0

var target: Node3D
var health_component: HealthComponent
var _fire_cooldown := 0.0
var _strafe_direction := 1.0
var _strafe_timer := 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
    add_to_group("hostiles")
    health_component = HealthComponentScript.new()
    health_component.name = "Health"
    health_component.max_health = max_health
    add_child(health_component)
    health_component.died.connect(_on_died)
    _strafe_direction = -1.0 if randf() < 0.5 else 1.0
    _strafe_timer = randf_range(1.2, 2.8)
    call_deferred("_resolve_target")

func _physics_process(delta: float) -> void:
    _fire_cooldown = max(_fire_cooldown - delta, 0.0)
    _strafe_timer -= delta
    if _strafe_timer <= 0.0:
        _strafe_direction *= -1.0
        _strafe_timer = randf_range(1.2, 2.8)
    if health_component != null and health_component.is_dead():
        velocity = Vector3.ZERO
        return
    _resolve_target()
    if target == null:
        velocity = velocity.move_toward(Vector3.ZERO, move_speed * delta)
        move_and_slide()
        return

    var flat := target.global_position - global_position
    flat.y = 0.0
    var distance := flat.length()
    var has_los := distance <= engagement_range and _has_line_of_sight(target)
    if has_los:
        _try_fire(target)

    var forward := flat.normalized() if flat.length_squared() > 0.01 else Vector3.FORWARD
    var lateral := Vector3(-forward.z, 0.0, forward.x) * _strafe_direction
    var desired := Vector3.ZERO

    if not has_los:
        desired = (forward + lateral * 0.65).normalized() * move_speed
    elif distance > preferred_range + 3.0:
        desired = (forward + lateral * 0.25).normalized() * move_speed
    elif distance < preferred_range - 3.0:
        desired = (-forward + lateral * 0.35).normalized() * move_speed
    else:
        desired = lateral * strafe_speed

    velocity.x = move_toward(velocity.x, desired.x, 10.0 * delta)
    velocity.z = move_toward(velocity.z, desired.z, 10.0 * delta)
    if flat.length_squared() > 0.01:
        rotation.y = lerp_angle(rotation.y, atan2(forward.x, forward.z), 7.5 * delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.2
    move_and_slide()

func apply_damage(amount: float, source: Node = null) -> void:
    if health_component != null:
        health_component.apply_damage(amount, source)

func _try_fire(victim: Node3D) -> void:
    if _fire_cooldown > 0.0 or not victim.has_method("apply_damage"):
        return
    _fire_cooldown = fire_interval + randf_range(-0.15, 0.2)
    var distance_factor := clamp(global_position.distance_to(victim.global_position) / engagement_range, 0.0, 1.0)
    var damage := fire_damage * lerp(1.0, 0.7, distance_factor)
    victim.call("apply_damage", damage, self)

func _has_line_of_sight(victim: Node3D) -> bool:
    var origin := global_position + Vector3.UP * 1.2
    var target_point := victim.global_position + Vector3.UP * 1.0
    var query := PhysicsRayQueryParameters3D.create(origin, target_point)
    query.exclude = [self]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return true
    var collider = hit.get("collider")
    return collider == victim or (collider is Node and victim.is_ancestor_of(collider))

func _on_died(_source: Node) -> void:
    set_physics_process(false)
    collision_layer = 0
    collision_mask = 0
    visible = false
    defeated.emit(self)

func _resolve_target() -> void:
    if target == null or not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player") as Node3D
