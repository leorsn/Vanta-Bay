extends CharacterBody3D
class_name VantaPoliceAgent

const HealthComponentScript = preload("res://scripts/health_component.gd")

@export var patrol_speed := 6.0
@export var pursuit_speed := 13.0
@export var turn_speed := 3.4
@export var sight_distance := 34.0
@export var stop_distance := 3.5
@export var unit_index := 0

var wanted: WantedManager
var search_offset := Vector3.ZERO
var health_component: HealthComponent

func _ready() -> void:
    add_to_group("police")
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    search_offset = _make_search_offset(unit_index)
    health_component = HealthComponentScript.new()
    health_component.name = "Health"
    health_component.max_health = 120.0
    add_child(health_component)
    health_component.died.connect(_on_died)

func _physics_process(delta: float) -> void:
    if health_component != null and health_component.is_dead():
        velocity = Vector3.ZERO
        return
    if wanted == null or wanted.state == "NONE" or wanted.state == "ESCAPED" or not _is_unit_active():
        velocity = velocity.move_toward(Vector3.ZERO, patrol_speed * delta)
        move_and_slide()
        return

    var destination := wanted.get_search_position() + search_offset
    var target := wanted.target
    if wanted.state == "PURSUIT" and target != null and is_instance_valid(target):
        if _has_line_of_sight(target):
            destination = target.global_position
            wanted.confirm_sighting(target.global_position, target)
        else:
            destination = wanted.get_search_position() + search_offset

    var flat := destination - global_position
    flat.y = 0.0
    if flat.length() <= stop_distance:
        velocity = velocity.move_toward(Vector3.ZERO, pursuit_speed * delta)
        move_and_slide()
        return

    var direction := flat.normalized()
    var desired_angle := atan2(direction.x, direction.z)
    rotation.y = lerp_angle(rotation.y, desired_angle, turn_speed * delta)
    var speed := pursuit_speed if wanted.state == "PURSUIT" else patrol_speed
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    if not is_on_floor():
        velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
    else:
        velocity.y = -0.2
    move_and_slide()

func apply_damage(amount: float, source: Node = null) -> void:
    if health_component == null:
        return
    if health_component.apply_damage(amount, source) and source is Node3D and wanted != null:
        wanted.report_crime((source as Node3D).global_position, 4, source as Node3D)

func _on_died(source: Node) -> void:
    set_physics_process(false)
    velocity = Vector3.ZERO
    if source is Node3D and wanted != null:
        wanted.report_crime((source as Node3D).global_position, 5, source as Node3D)

func _is_unit_active() -> bool:
    if wanted == null:
        return false
    var required_units := 1
    if wanted.stars >= 2:
        required_units = 2
    if wanted.stars >= 3:
        required_units = 3
    return unit_index < required_units

func _has_line_of_sight(target: Node3D) -> bool:
    var origin := global_position + Vector3.UP * 1.2
    var target_point := target.global_position + Vector3.UP * 1.0
    if origin.distance_to(target_point) > sight_distance:
        return false
    var query := PhysicsRayQueryParameters3D.create(origin, target_point)
    query.exclude = [self]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return true
    var collider = hit.get("collider")
    return collider == target or (collider is Node and target.is_ancestor_of(collider))

func _make_search_offset(index: int) -> Vector3:
    var offsets := [
        Vector3.ZERO,
        Vector3(12.0, 0.0, 8.0),
        Vector3(-11.0, 0.0, 10.0),
        Vector3(8.0, 0.0, -13.0),
        Vector3(-14.0, 0.0, -7.0)
    ]
    return offsets[index % offsets.size()]
